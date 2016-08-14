###

 Class:  TableView
 =====================================================================================

 This is a multi-purpose table view that handles many aspects of a fast display and
 edit table/grid.

 @example:
 new TableView $(".tableHolder")

 Events:
 =====================================================================================

 "click_col" : will trigger when a row is clicked with the name "col", for example
 @example: table.on "click_zipcode", (row, e) =>

###

globalKeyboardEvents = new EvEmitter()

$(document).on "keyup", (e)=>

	if e.target == document.body
		if e.keyCode == 38
			console.log "DOC KEY [up]"
			globalKeyboardEvents.emitEvent "up", []
		else if e.keyCode == 40
			console.log "DOC KEY [down]"
			globalKeyboardEvents.emitEvent "down", []
		else if e.keyCode == 37
			console.log "DOC KEY [left]"
			globalKeyboardEvents.emitEvent "left", []
		else if e.keyCode == 39
			console.log "DOC KEY [right]"
			globalKeyboardEvents.emitEvent "right", []
		else if e.keyCode == 9
			console.log "DOC KEY [tab]"
			globalKeyboardEvents.emitEvent "tab", []
		else if e.keyCode == 13
			console.log "DOC KEY [enter]"
			globalKeyboardEvents.emitEvent "enter", []

	return true

$(document).on "mousedown", (e)=>
	globalKeyboardEvents.emitEvent "global_mouse_down", [ e ]
	return true

class TableView

	# @property [String] imgChecked html to be used when checkbox is checked
	imgChecked     : "<img src='images/checkbox.png' width='16' height='16' alt='Selected' />"

	# @property [String] imgNotChecked html to be used when checkbox is not checked
	imgNotChecked  : "<img src='images/checkbox_no.png' width='16' height='16' alt='Selected' />"

	##|
	##| ******************************[ Events and event related functions or notes ]*******************************
	##|

	## -------------------------------------------------------------------------------------------------------------
	## to add the default table row click event
	##
	## @param [Object] row the data of row in form object that is clicked
	## @param [Event] the clicked jquery event object
	## @event defaultRowClick
	## @return [Boolean]
	##
	defaultRowClick: (row, e) =>
		# console.log "DEF ROW CLICK=", row, e
		false

	## -------------------------------------------------------------------------------------------------------------
	## function to execute when one of the checkbox is checked
	##
	## @param [String] checkbox_key to identify the checkbox key
	## @param [String] value to identify the checkbox
	##
	onSetCheckbox: (checkbox_key, value) =>
		##|
		##|  By default this is a property
		# api.SetCheckbox window.currentProperty.id, checkbox_key, value
		console.log "onSetCheckbox(", checkbox_key, ",", value, ")"

	## -------------------------------------------------------------------------------------------------------------
	## function called when the right click context menu event on a header column.
	##
	## @event onContextMenuHeader
	## @param [Object] coords coordinates {x:300,y:500}
	## @param [Object] column the current column which is clicked
	##
	onContextMenuHeader: (coords, column) =>

		console.log "COORDS=", coords
		selectedColumn = @colList.filter (columnObj) =>
			return columnObj.col.name is column
		.pop()

		##| if column is sortable in dataTypes
		if selectedColumn.col.sortable
			popupMenu = new PopupMenu "Column: #{column}", coords.x-150, coords.y

			##| add sorting menu item
			popupMenu.addItem "Sort Ascending", () =>
				popupMenu.closeTimer()
				@internalApplySorting()
			popupMenu.addItem "Sort Descending", () =>
				popupMenu.closeTimer()
				@internalApplySorting()

		if @customizableColumns
			if !popupMenu
				popupMenu = new PopupMenu "Column: #{column}", coords.x-150, coords.y
			popupMenu.addItem "Customize", (coords, data) =>
				popupMenu.closeTimer()
				@onConfigureColumns
					x: coords.x
					y: coords.y


		if typeof @tableCacheName != "undefined" && @tableCacheName != null
			if !popupMenu
				popupMenu = new PopupMenu "Column: #{column}", coords.x-150, coords.y
			popupMenu.addItem "Configure Columns", (coords, data) =>
				@onConfigureColumns
					x: coords.x
					y: coords.y

	## -------------------------------------------------------------------------------------------------------------
	## Display a popup to adjust the column of the table
	##
	## @param [Object] coords coordinates including x and y
	## @event onConfigureColumns
	##
	onConfigureColumns: (coords) =>
		popup = new PopupWindowTableConfiguration "Configure Columns", coords.x-150, coords.y
		popup.show(this)

	## -------------------------------------------------------------------------------------------------------------
	## returns the numbe of rows checked
	##
	## @return [Integer] no of rows checked in current table
	##
	numberChecked: () =>
		return Object.keys(@rowDataSelected).length

	## -------------------------------------------------------------------------------------------------------------
	## Initialize the class by sending in the ID of the tag you want to beccome a managed table.
	## This should be a simple <table id='something'> tag.
	##
	## @param [JQueryElement] elTableHolder the $() referenced element that will hold the table
	## @param [Boolean] showCheckbox if check boxes are visible or not
	##
	constructor: (@elTableHolder, @showCheckboxes) ->

		# @property [Array] list of columns as array
		@colList        = []

		# @property [Array] list of rows as array
		@rowDataRaw      = []
		@rowDataSelected = {}

		# @property [Boolean] to show headers of table
		@showHeaders    = true

		# @property [Boolean] to show textbox to filter data
		@showFilters	= true

		@allowSelectCell = true

		# @property [Object] currentFilters current applied filters to the table
		@currentFilters = {}
		@currentGroups  = []

		# @property [Boolean|Function] callback to call on context menu click
		@contextMenuCallbackFunction = 0

		# @property [Boolean|Function] add menu to context menu
		@contextMenuCallSetup        = 0

		# @property [int] the max number of rows that can be selected
		@checkboxLimit = 1

		# @property [Boolean] showCheckboxes if checkbox to be shown or not default false
		if !@showCheckboxes? then @showCheckboxes = false

		if (!@elTableHolder[0])
			console.log "Error: Table id #{@elTableHolder} doesn't exist"

		#@property [int] the offset from the top to start showing
		@offsetShowingTop  = 0
		@offsetShowingLeft = 0

		##|
		##|  The height of each cell to draw
		##|
		@dataCellHeight   = 24
		@headerCellHeight = 24
		@filterCellHeight = 20

		##|
		##|  Event manager for Event Emitter style events
		GlobalClassTools.addEventManager(this)
		@on "added_event", @onAddedEvent

		globalKeyboardEvents.on "up", @moveCellUp
		globalKeyboardEvents.on "down", @moveCellDown
		globalKeyboardEvents.on "left", @moveCellLeft
		globalKeyboardEvents.on "right", @moveCellRight
		globalKeyboardEvents.on "tab", @moveCellRight
		globalKeyboardEvents.on "enter", @pressEnter
		globalKeyboardEvents.on "global_mouse_down", @onGlobalMouseDown
		globalKeyboardEvents.on "change", @onGlobalDataChange

		##|
		##|  Create a unique ID for the table, that doesn't change
		##|  even if the table is re-drawn
		if !@gid?
			@gid = GlobalValueManager.NextGlobalID()


	## -------------------------------------------------------------------------------------------------------------
	## to add the join table with current rendered table
	##
	## @example table.addJoinTable "county", null, "county"
	## @param [String] tableName name of the table to add as join table from datamap
	## @param [Function|null] columnReduceFunction will be applied to each row and each column and if returns true then only column will be included
	## @param [String] sourceField the name of the source property
	## @return [Boolean]
	##
	addJoinTable: (tableName, columnReduceFunction, sourceField) =>

		columns = DataMap.getColumnsFromTable tableName, columnReduceFunction
		for col in columns
			if col.source != sourceField
				c = new TableViewCol tableName, col
				console.log "Setting joinKey ", sourceField
				c.joinKey = sourceField
				c.joinTable = @primaryTableName
				@colList.push(c)

		true

	## -------------------------------------------------------------------------------------------------------------
	## to add the table in the view from datamap
	##
	## @example tableView.addTable "zipcode"
	## @param [String] tableName name of the table to consider from datamap
	## @param [Function] columnReduceFunction will be applied to each row and each column and if returns true then only column will be included
	## @param [Function] reduceFunction will be applied to each row and if returns true then only row will be included
	## @return [Boolean]
	##
	addTable: (tableName, @columnReduceFunction, @reduceFunction) =>

		@primaryTableName = tableName

		##|
		##|  Add a checkbox column if needed
		if @showCheckboxes
			c = new TableViewColCheckbox(tableName)
			@colList.push c

		##|
		##|  Find the columns for the specific table name
		columns = DataMap.getColumnsFromTable(tableName, @columnReduceFunction)
		for col in columns
			c = new TableViewCol tableName, col
			@colList.push(c)

		true

	## -------------------------------------------------------------------------------------------------------------
	## Add a column to the end of the table
	##|
	addActionColumn: (name, callback)=>

		button = new TableViewColButton(name, name)
		@colList.push button
		@on "click_#{name}", callback

		true

	## -------------------------------------------------------------------------------------------------------------
	## Table cache name is set, this allows saving/loading table configuration
	##
	## @param [String] tableCacheName the cache name to attach with table
	##
	setTableCacheName: (@tableCacheName) =>

	## -------------------------------------------------------------------------------------------------------------
	## make the table with fixed header and scrollable
	##
	## @param [Boolean] fixedHeader if header is fixed or not
	##
	setSimpleAndFixed: () =>

		@showFilters     = false
		@showHeaders     = false
		# @allowSelectCell = false
		@fixedHeader     = true

		# $(window).on 'resize', () =>
			# @elTableHolder.find('.table-header .tableview').width(@elTableHolder.find('.table-body .tableview').width())

	## -------------------------------------------------------------------------------------------------------------
	## make the table with fixed header and scrollable
	##
	## @param [Boolean] fixedHeader if header is fixed or not
	##
	setFixedHeaderAndScrollable: (@fixedHeader = true) =>
		$(window).on 'resize', () =>
			@elTableHolder.find('.table-header .tableview').width(@elTableHolder.find('.table-body .tableview').width())
		$('a[data-toggle="tab"]').on 'shown.bs.tab', (e)=>

			if @elTableHolder.width() > 0
				@setHolderToBottom()

	## -------------------------------------------------------------------------------------------------------------
	## function to make column filter as popup instead of plain text
	##
	## @example
	##		tableview.setColumnFilterAsPopup("sample") where sample is column name or source
	## @param [String] colName column name or source to be used in the filter
	##
	setColumnFilterAsPopup: (colName) ->
		col = @colList.filter (column) =>
				return column.col.name is colName
		if ! col.length
			col = @colList.filter (column) =>
					return column.getSource() is colName
		if ! col.length
			throw new Error "column with name or source #{colName} is not found"
		col = col.pop()
		@internalCountNumberOfOccurenceOfPopup(col,true)

	## -------------------------------------------------------------------------------------------------------------
	## remove the checkbox for all items except those included in the bookmark array that comes from the server
	##
	## @param [Array] bookmarkArray the array of key to consider as bookmark
	## @return [Boolean]
	##
	resetChecked : () =>
		return false

	getRowSelected: (id)=>
		val = DataMap.getDataField @primaryTableName, id, "row_selected"
		if val? and val == true then return true
		return false

	##|
	##| Toggle a row as selected/not selected
	toggleRowSelected: (row) =>

		val = @getRowSelected row.id
		newVal = val == false

		if val

			row.row_selected = false
			DataMap.getDataMap().updatePathValueEvent "/#{@primaryTableName}/#{row.id}/row_selected", false
			delete @rowDataSelected[row.id]

		else

			if @checkboxLimit == 1
				for id in Object.keys(@rowDataSelected)
					DataMap.getDataMap().updatePathValueEvent "/#{@primaryTableName}/#{id}/row_selected", false
				@rowDataSelected = {}

			console.log "Setting /#{@primaryTableName}/#{row.id}/row_selected = true"
			DataMap.getDataMap().updatePathValueEvent "/#{@primaryTableName}/#{row.id}/row_selected", true
			@rowDataSelected[row.id] = true

		@resetChecked()
		# @updateVisibleText()
		true

	scrollUp: (amount)=>
		@offsetShowingTop += amount
		@updateVisibleText()
		true

	scrollRight: (amount)=>
		visCol = @getTableVisibleCols()
		maxCol = @getTableTotalCols()

		@offsetShowingLeft += amount
		if @offsetShowingLeft + visCol > maxCol
			@offsetShowingLeft = maxCol - visCol - 1

		if @offsetShowingLeft < 1
			@offsetShowingLeft = 0

		@updateVisibleText()
		true

	onGlobalDataChange: (path, newData)=>
		##|
		##|  Something globally change the value of a path, see if we care
		cell = @findPathVisible(path)
		if cell != null
			# console.log "Found cell for #{path}"
			# cell.el.css "border", "2px solid green"
			@updateVisibleText()

		true

	onGlobalMouseDown: (e)=>
		##|
		##|  remove focus on a mouse down someplace, it will
		##|  get reset if the mouse was on this table
		@setFocusCell null, null

	pressEnter: (e)=>

		if !@currentFocusCell?
			return false

		parts = @currentFocusPath.split "/"
		tableName = parts[1]
		fieldName = parts[2]
		record_id = parts[3]

		for row in @rowDataRaw
			if row.id.toString() == record_id.toString()

				##|  Use the new event manager
				console.log "PRESS ENTER: [#{col}]", row
				@emitEvent "click_#{fieldName}", [ row, e ]
				@emitEvent "click_row", [ row, e ]

		true

	## -------------------------------------------------------------------------------------------------------------
	## to setup event internally for the table
	##
	internalSetupMouseEvents: () =>

		@virtualScrollV.on "scroll_y", (amount)=>
			@scrollUp(amount)
			true

		@virtualScrollV.on "scroll_to", (amount)=>
			@offsetShowingTop = amount
			@scrollUp(0)
			true

		@virtualScrollH.on "scroll_x", (amount)=>
			# console.log "SCROLL X = ", amount
			true

		@virtualScrollH.on "scroll_to", (amount)=>
			@scrollRight(amount)
			true

		@elTheTable.bind "click touchbegin", (e) =>

			e.preventDefault()
			e.stopPropagation()

			data = @findRowFromPath e.path
			col  = @findColFromPath e.path

			if data? and data.id?
				@setFocusCell(e.vr, e.vc)
			else
				@setFocusCell(null)

			if !data?
				return false

			if data == "Filter"
				##|
				##|  Don't do anything here for filter columns
				return false

			if data == "Header"
				##|
				##|  TODO: Add sorting here
				return false

			if col == "row_selected"
				##|
				##|  Toggle row selection
				@toggleRowSelected data
			else
				##|
				##|  Use the new event manager
				@emitEvent "click_#{col}", [ data, e ]
				@emitEvent "click_row", [ data, e ]

				for c in @colList
					if c.getSource() == col
						if c.getEditable()
							DataMap.getDataMap().editValue e.path, e.target

			false

	## -------------------------------------------------------------------------------------------------------------
	## to add context menu with header column click
	##
	## @example
	##		tableview.setupContextMenu (coordinates,data) ->
	## @param [Function] contextMenuCallbackFunction function to execute on the click of context menu item
	## @return [Boolean]
	##
	setupContextMenu: (@contextMenuCallbackFunction) =>

		if @contextMenuCallSetup == 1 then return true
		@contextMenuCallSetup = 1

		@elTableHolder.bind "contextmenu", (e) =>

			coords    = GlobalValueManager.GetCoordsFromEvent(e)
			data      = @findRowFromElement e.target

			if data == null
				$target = $ e.target

				##|
				##|  Check to see if it's a header column
				if $target.is "th"
					@onContextMenuHeader coords, $target.text()
					console.log "Click on header:", coords, $target.text()
					return true

			if typeof @contextMenuCallbackFunction == "function"
				@contextMenuCallbackFunction coords, data

			true

		true



	## -------------------------------------------------------------------------------------------------------------
	## internal function to apply sorting on table with column and sorting type
	##
	## @param [Object] column column on which sorting should be applied
	## @param [String] type it can be ASC|DESC
	##
	internalApplySorting: () =>

		@rowDataRaw.sort (a, b)=>

			for c in @colList

				aValue = DataMap.getDataField c.tableName, a.id, c.getSource()
				bValue = DataMap.getDataField c.tableName, b.id, c.getSource()

				if c.sort? and c.sort == 1
					if aValue < bValue then return 1
					if aValue > bValue then return -1

				else if c.sort? and c.sort == -1
					if aValue < bValue then return -1
					if aValue > bValue then return 1

		@updateVisibleText()
		true

	## -------------------------------------------------------------------------------------------------------------
	## Apply filters stored in "currentFilters" to each column and show/hide the rows
	##
	applyFilters: (rowData) =>

		##|
		##| Build the filters

		filters = []
		for tableName, fieldList of @currentFilters
			for fieldName, filterValue of fieldList
				filters.push
					tableName : tableName
					keyName   : fieldName
					filter    : new RegExp filterValue, "i"

		filteredRowData = []
		for row in rowData

			##|
			##| Each row has the element (el) and the children TD nodes in children
			keepRow = true
			for f in filters
				if not keepRow then continue

				rowValue = DataMap.getDataField(f.tableName, row, f.keyName)
				if not f.filter.test rowValue
					keepRow = false

			if not keepRow
				continue

			filteredRowData.push(row)

		return filteredRowData

	updateFullHeight: ()=>
		if @fixedHeader then return
		h = 0
		if @showHeaders then h = h + @headerCellHeight
		if @showFilters then h = h + @filterCellHeight
		h = h + (@totalAvailableRows * @dataCellHeight)
		@elTableHolder.height(h)
		return h

	## -------------------------------------------------------------------------------------------------------------
	## function to update row data on the screen if new data has been added in datamapper they can be considered
	##
	updateRowData: () =>

		@rowDataRaw = []
		allData = DataMap.getValuesFromTable @primaryTableName, @reduceFunction

		if @currentGroups.length == 0
			##|
			##|  Simple data, no grouping
			filteredData = @applyFilters(allData)
			for keyName, obj of filteredData
				@rowDataRaw.push { id: obj.id, group: null }

			@totalAvailableRows = @rowDataRaw.length
			@updateFullHeight()
			return

		##|
		##|  Apply grouping filters
		groupedData        = {}
		@rowDataRaw        = []
		currentGroupNumber = 0

		for name in @currentGroups

			displayName = name
			for col in @colList
				if col.getSource() == name then displayName = col.getName()

			for item in allData
				value = DataMap.getDataField @primaryTableName, item.id, name
				if !groupedData[value]?
					groupedData[value] = []

				groupedData[value].push item.id

			for value in Object.keys(groupedData).sort()

				currentGroupNumber++
				if currentGroupNumber > 7 then currentGroupNumber = 1

				filteredData = @applyFilters(groupedData[value])
				if filteredData.length > 0
					##|
					##|  There are rows of data in this group so add the group to the row list.
					@rowDataRaw.push
						id    : null
						type  : "group"
						name  : "#{displayName}: #{value}"
						group : currentGroupNumber
						count : filteredData.length

					for id in filteredData
						@rowDataRaw.push { id: id, visible: true, group: currentGroupNumber }

		console.log "GroupDate=", groupedData
		console.log "RowData=", @rowDataRaw

		@totalAvailableRows = @rowDataRaw.length
		@updateFullHeight()
		return true

	## -------------------------------------------------------------------------------------------------------------
	## set the holder element to go to the bottom of the screen
	##
	setHolderToBottom: () =>

		height = $(window).height()
		pos = @elTableHolder.position()

		newHeight = height - pos.top
		@elTableHolder.height(newHeight)

		##|
		##|  If the width of the table scrolls, this fixes it
		newWidth = @elTableHolder.width()

		if @resizeHolderEvent?

			if newWidth != @lastNewWidth or newHeight != @lastNewHeight
				# console.log "setHolderToBottom, WindowHeight=#{height}, Table Position=", pos, " newHeight=#{newHeight}, newWidth=#{newWidth}"
				@render()

			return true

		else

			@resizeHolderEvent = true
			$(window).on "resize", ()=>
				##|
				##|  Automatically adjust the position if the screen size changes
				@setHolderToBottom()
				true

		@lastNewHeight = newHeight
		@lastNewWidth  = newWidth
		true


	## -------------------------------------------------------------------------------------------------------------
	## function to make column customizable in the popup
	##
	## @example
	##		table.allowCustomize()
	## @param [Boolean] customizableColumns
	##
	allowCustomize: (@customizableColumns = true) ->

	##|
	##|  Total available rows to display excluding headers
	getTableTotalRows: ()=>
		return @totalAvailableRows

	getTableTotalCols: ()=>
		count = Object.keys(@colByNum).length
		return count

	getTableVisibleWidth: ()=>
		maxWidth = @elTableHolder.width()
		if @virtualScrollV.visible then maxWidth -= 20
		return maxWidth

	getTableVisibleHeight: ()=>
		maxHeight  = @elTableHolder.height()
		if @virtualScrollH.visible then maxHeight -= 20
		return maxHeight

	##|
	##|  Number of visible rows
	getTableVisibleRows: ()=>

		y           = 0
		visRowCount = 0
		rowNum      = @offsetShowingTop
		maxHeight   = @getTableVisibleHeight()
		totalRows   = @getTableTotalRows()

		while y < maxHeight

			if rowNum >= totalRows
				break

			y = y + @getRowHeight({rowNum:rowNum, visibleRow:visRowCount})
			visRowCount++
			rowNum++

		return visRowCount

	##|
	##|  Number of visible columns
	getTableVisibleCols: ()=>

		visColCount = 0
		x           = 0
		colNum      = @offsetShowingLeft
		maxWidth    = @getTableVisibleWidth()
		totalCols   = @getTableTotalCols()

		while x < maxWidth and colNum < totalCols

			while (colNum < totalCols) and @shouldSkipCol(location)
				colNum++

			if colNum >= totalCols
				break

			x = x + @getColWidth { visibleCol: visColCount, colNum: colNum }
			visColCount++
			colNum++

		return visColCount

	##|
	##|  Compute the width of a given column
	getColWidth: (location)=>

		if location.cellType == "group"
			maxWidth = @getTableVisibleWidth()
			if location.visibleCol == 1 then return maxWidth-200
			if location.visibleCol == 2 then return 100
			if location.visibleCol == 3 then return 90
			return 0

		if !@colByNum[location.colNum]? then return 0
		return @colByNum[location.colNum].actualWidth

	##|
	##|  Compute the height of a given row
	getRowHeight: (location)=>
		return @dataCellHeight

	##|
	##|  Return true if a cell is editable
	##|
	getCellEditable: (location)=>
		if !@colByNum[location.colNum]? then return false
		return @colByNum[location.colNum].getEditable()

	getCellClickable: (location)=>
		if @colByNum[location.colNum]? and @colByNum[location.colNum].getFormatterName() == "table_button"
			return true
		return false

	##|
	##|  Returns true if the row/column should have the darker color
	##|  background (striped rows on a table)
	##|
	getCellStriped: (location)=>
		if (@showHeaders or @showFilters) and location.visibleRow == 0 then return false
		if (@showHeaders and @showFilters) and location.visibleRow == 1 then return false
		if location.cellType == "group" then return false
		return location.visibleRow % 2 == 0

	getCellGroupNumber: (location)=>
		if location.cellType == "group" then return @rowDataRaw[location.rowNum].group
		if location.cellType == "invalid" or location.visibleCol > 0 then return null
		if !@rowDataRaw[location.rowNum]? then return null
		return @rowDataRaw[location.rowNum].group

	##|
	##|  Return right/left/center - left is assumed by default
	getCellAlign: (location)=>
		if location.cellType == "group"
			if location.visibleCol == 1 then return "left"
			return "right"

		return @colByNum[location.colNum].getAlign()

	getCellTablename: (location)=>
		return @colByNum[location.colNum].tableName

	getCellSource: (location)=>
		return @colByNum[location.colNum].getSource()

	getCellRecordID: (location)=>
		if !@rowDataRaw[location.rowNum]? then return 0
		return @rowDataRaw[location.rowNum].id

	getCellFormatterName: (location)=>
		return @colByNum[location.colNum].getFormatterName()

	shouldAdvanceCol: (location)=>
		return true

	setHeaderField: (location)=>

		if location.cell.children.length == 0 and location.cell.currentCol == location.colNum
			return

		location.cell.html ""
		if location.visibleRow == 0
			@colByNum[location.colNum].RenderHeader "", location.cell
		else
			if location.cell.children.length == 0
				location.cell.addClass "dataFilterWrapper"
				filter = location.cell.add "input", "dataFilter"
				filter.setDataPath "/#{@colByNum[location.colNum].tableName}/Filter/#{@colByNum[location.colNum].getSource()}"
				filter.bind "keyup", @onFilterKeypress

		true

	setDataField: (location)=>

		if location.cellType == "invalid"
			location.cell.hide()
			return

		if location.cellType == "group"
			if location.visibleCol == 1
				location.cell.html @rowDataRaw[location.rowNum].name
			else if location.visibleCol == 2
				location.cell.html ""
			else if location.visibleCol == 3
				location.cell.html "#{@rowDataRaw[location.rowNum].count}"
			return

		col = @colByNum[location.colNum]
		if col.getSource() == "row_selected"

			if @getRowSelected(@rowDataRaw[location.rowNum].id)
				location.cell.html @imgChecked
			else
				location.cell.html @imgNotChecked

		else if col.render?
			location.cell.html col.render(@rowDataRaw[location.rowNum][col.getSource()], @rowDataRaw[location.rowNum])
		else
			displayValue = DataMap.getDataFieldFormatted col.tableName, @rowDataRaw[location.rowNum].id, col.getSource()
			location.cell.html displayValue

		true

	shouldSkipCol: (location)=>
		if @colByNum[location.colNum]? and @colByNum[location.colNum].isGrouped? and @colByNum[location.colNum].isGrouped == true
			return true
		return false

	##|
	##|  Returns a state record for the current row
	##|  data - Cells of data
	##|  locked - Cells of header or locked content
	##|  group - Starting a new group
	##|  skip - Skip this row
	##|  invalid - Invalid row
	##|
	getRowType: (location)=>
		if @isHeaderCell(location) then return "locked"
		if !@rowDataRaw[location.rowNum]? then return "invalid"
		if @rowDataRaw[location.rowNum]? and @rowDataRaw[location.rowNum].type? then return "group"
		return "data"

	getCellType: (location)=>
		if @isHeaderCell(location) then return "locked"
		if not location.rowNum? or !@rowDataRaw[location.rowNum]? then return "invalid"
		if !@rowDataRaw[location.rowNum]? then return "invalid"
		if @rowDataRaw[location.rowNum].type? then return @rowDataRaw[location.rowNum].type
		return "data"

	isHeaderCell: (location)=>
		if location.visibleRow == 1 and (@showHeaders and @showFilters) then return true
		if location.visibleRow == 0 and (@showHeaders or @showFilters) then return true
		return false

	##|
	##|  Draw a single row, returns the next rowNum.
	##|
	updateVisibleTextRow: (location, rowHeight, maxWidth, totalColCount)=>

		x                   = 0    ## Pixel location of current column
		location.visibleCol = 0
		location.colNum     = 0

		while x < maxWidth

			if @shadowCells[location.visibleRow].children.length <= location.visibleCol
				@shadowCells[location.visibleRow].addDiv "cell"
				@shadowCells[location.visibleRow].children[location.visibleCol].setAbsolute()

			isHeaderRow       = @isHeaderCell(location)
			location.groupNum = @getCellGroupNumber(location)
			location.cell     = @shadowCells[location.visibleRow].children[location.visibleCol]
			location.cellType = @getCellType(location)

			if isHeaderRow and Object.keys(@currentGroups).length > 0 and location.visibleCol == 0
				@shadowCells[location.visibleRow].children[location.visibleCol].move x, 0, 10, rowHeight
				x += 10
				location.visibleCol++
				continue

			if !isHeaderRow and location.groupNum? and location.visibleCol == 0
				@shadowCells[location.visibleRow].children[location.visibleCol].move x, 0, 10, rowHeight
				@shadowCells[location.visibleRow].children[location.visibleCol].setClassOne "groupRowChart#{location.groupNum}", /^groupRowChart/
				location.visibleCol++
				x += 10
				continue

			while (location.colNum < totalColCount) and @shouldSkipCol(location)
				location.colNum++
				continue

			colWidth = @getColWidth(location)
			if location.colNum + 1 == totalColCount
				# console.log "last column #{location.colNum} == #{totalColCount}, width was=#{colWidth} want=#{maxWidth-x}"
				colWidth = maxWidth - x

			if location.colNum >= totalColCount
				break

			location.cell.show()
			location.cell.removeClass "groupRow"

			##|
			##|  Get the table and column for this cell
			tableName  = @getCellTablename location
			sourceName = @getCellSource location

			##|
			##|  Align right/center as left is the default
			location.cell.setClass "even", @getCellStriped(location)
			align = @getCellAlign(location)
			location.cell.setClass "text-right", (align == "right")
			location.cell.setClass "text-center", (align == "center")

			##|
			##|  Apply one and only one formatting type
			formatter  = @getCellFormatterName(location)
			location.cell.setClassOne "type_#{formatter}", /^type_/
			location.cell.setClassOne "groupRowChart#{location.groupNum}", /^groupRowChart/

			##|
			##|  Set the column / row data on the element
			location.cell.setDataValue "vr", location.visibleRow
			location.cell.setDataValue "vc", location.visibleCol
			location.cell.setDataValue "rn", location.rowNum
			location.cell.setDataValue "cn", location.colNum

			location.cell.setClass "tableHeaderField", isHeaderRow
			location.cell.move x, 0, colWidth, rowHeight

			if isHeaderRow

				location.cell.setDataPath "/#{tableName}/Header/#{sourceName}"
				@setHeaderField(location)

			else

				recordId = @getCellRecordID(location)
				location.cell.setDataPath "/#{tableName}/#{recordId}/#{sourceName}"
				location.cell.setClass "clickable", @getCellClickable(location)
				location.cell.setClass "editable", @getCellEditable(location)
				location.cell.setClass "row_checked", @getRowSelected(recordId)
				@setDataField(location)

			if @shouldAdvanceCol(location) then location.colNum++
			location.visibleCol++
			x += colWidth

		##|
		##|  Hide any remaining cached cells on the right
		while @shadowCells[location.visibleRow].children[location.visibleCol]?
			@shadowCells[location.visibleRow].children[location.visibleCol].hide()
			location.visibleCol++

		true

	updateVisibleText: ()=>

		if !@offsetShowingTop? or @offsetShowingTop < 0
			@offsetShowingTop = 0

		if !@offsetShowingLeft? or @offsetShowingLeft < 0
			@offsetShowingLeft = 0

		@updateScrollbarSettings()

		y               = 0
		groupState      = null
		maxHeight       = @getTableVisibleHeight()
		maxWidth        = @getTableVisibleWidth()
		totalColCount   = @getTableTotalCols()
		totalRowCount   = @getTableTotalRows()
		refreshRequired = false

		location =
			visibleRow : 0
			rowNum     : @offsetShowingTop

		# console.log "updateVisibleText offsetShowingTop=", @offsetShowingTop, " offsetShowingLeft=", @offsetShowingLeft, " maxRow=", totalRowCount, "maxCol=", totalColCount
		while y < maxHeight

			rowHeight = @getRowHeight(location)
			state = @getRowType(location)

			if !@shadowCells[location.visibleRow]?
				@shadowCells[location.visibleRow] = @elTheTable.addDiv "tableRow"
				@shadowCells[location.visibleRow].setAbsolute()
				@shadowCells[location.visibleRow].show()

			##|
			##|  Row div goes the entire width
			@shadowCells[location.visibleRow].move 0, y, maxWidth, rowHeight

			if state == "invalid"
				##|
				##|  Scroll down too far
				if @offsetShowingTop > 0
					@offsetShowingTop--
					refreshRequired = true

				break

			else if state == "skip"
				location.rowNum++
				continue

			else if state == "group"
				@shadowCells[location.visibleRow].show()
				@shadowCells[location.visibleRow].removeClass "tableRow"
				@updateVisibleTextRow location, rowHeight, maxWidth, totalColCount
				location.rowNum++

			else if state == "locked"
				@shadowCells[location.visibleRow].show()
				@shadowCells[location.visibleRow].removeClass "tableRow"
				@updateVisibleTextRow location, rowHeight, maxWidth, totalColCount

			else if state == "data"
				@shadowCells[location.visibleRow].show()
				@shadowCells[location.visibleRow].addClass "tableRow"
				@updateVisibleTextRow location, rowHeight, maxWidth, totalColCount
				location.rowNum++

			else
				console.log "Unknown state at v=#{visibleRow}, r=#{rowNum}:", state
				location.rowNum++

			y += rowHeight
			location.visibleRow++

		while @shadowCells[location.visibleRow]?
			@shadowCells[location.visibleRow].hide()
			location.visibleRow++

		if refreshRequired
			@updateVisibleText()

		true

	##|
	##|  Up the visibility and settings of the scrollbars
	updateScrollbarSettings: ()=>

		currentVisibleCols = @getTableVisibleCols()
		currentVisibleRows = @getTableVisibleRows()

		maxAvailableRows = @getTableTotalRows()
		maxAvailableCols = @getTableTotalCols()

		##|
		##|  Don't show more rows than fit on the screen
		if @offsetShowingTop >= maxAvailableRows - currentVisibleRows
			# console.log "updateScrollbarSettings offsetShowingTop #{@offsetShowingTop} >= #{maxAvailableRows} - #{currentVisibleRows}"
			@offsetShowingTop = maxAvailableRows - currentVisibleRows

		if @offsetShowingLeft >= maxAvailableCols - currentVisibleCols
			@offsetShowingLeft = maxAvailableCols - currentVisibleCols
			# console.log "updateScrollbarSettings offsetShowingLeft #{@offsetShowingLeft} >= #{maxAvailableCols} - #{currentVisibleCols}"

		##|
		##|  Scrollbar settings show/hide
		console.log "updateScrollbarSettings H:(#{currentVisibleCols} vs #{maxAvailableCols}) V:(#{currentVisibleRows} vs #{maxAvailableRows})"

		@virtualScrollV.setRange 0, maxAvailableRows, currentVisibleRows, @offsetShowingTop
		@virtualScrollH.setRange 0, maxAvailableCols, currentVisibleCols, @offsetShowingLeft

	##|
	##|  For a standard table, adjust the width of the columns to fit the space available
	##|  and if it's not a close fit, then scroll the table instead
	##|
	layoutShadow: ()=>

		maxWidth   = @getTableVisibleWidth()

		##|
		##|  Look at all the columns, determine the likely width
		widthLimit   = Math.trunc(maxWidth)
		missingCount = 0
		colNum       = 0

		for i in @colList
			if !i.visible then continue

			calcWidth = i.calculateWidth()
			if !calcWidth? or calcWidth < 0
				missingCount++
				i.actualWidth = null
			else
				maxWidth -= calcWidth
				i.actualWidth = calcWidth

			colNum++

		##|
		##|  Split the remaining space
		if missingCount > 0
			unallocatedSpace = Math.ceil(maxWidth / missingCount)
			if unallocatedSpace < 60 then unallocatedSpace = 60

		totalWidth = 0
		totalColCount = 0
		for i in @colList

			if not i.visible then continue

			if totalColCount == colNum-1 and !i.actualWidth?
				i.actualWidth = widthLimit - totalWidth
				if i.actualWidth < 60
					i.actualWidth = 60

			if !i.actualWidth?
				i.actualWidth = unallocatedSpace

			totalWidth += i.actualWidth
			totalColCount++

		##|
		##|  Remove or add a pixel until we have the exact amount
		##|  but only if we are smaller than available size or very close to it
		if totalWidth - 50 < widthLimit

			attemptCounter = 0
			while Math.ceil(totalWidth) != Math.ceil(widthLimit) and attemptCounter++ < 1500

				# console.log "Trying to fix, totalWidth=#{totalWidth}, widthLimit=#{widthLimit}"

				found = false
				for i in @colList
					if not i.visible then continue
					if i.getSource() == "row_selected" then continue
					if i.getFormatterName() != "text" then continue
					found = true
					if totalWidth > widthLimit
						i.actualWidth--
						totalWidth--
					else if totalWidth < widthLimit
						i.actualWidth++
						totalWidth++

				if not found then break

				# console.log "Actual=", widthLimit, "Total Width = ", totalWidth
		true

	## -------------------------------------------------------------------------------------------------------------
	## function to render the added table inside the table holder element
	##
	## @example tableview.render()
	## @return [Boolean]
	##
	render: () =>

		if !@shadowCells?
			@shadowCells = {}

		if !@fixedHeader
			@elTableHolder.width("100%")

		##|
		##|  Get the data from that table
		if !@rowDataRaw? or @rowDataRaw.length == 0
			@updateRowData()

		@elTableHolder.html("")
		@widgetBase = new WidgetBase()

		tableWrapper   = @widgetBase.addDiv "table-wrapper", "tableWrapper#{@gid}"
		outerContainer = tableWrapper.addDiv "outer-container"
		@elTheTable    = outerContainer.addDiv "inner-container tableview"

		@virtualScrollV = new VirtualScrollArea outerContainer, true
		@virtualScrollH = new VirtualScrollArea outerContainer, false

		##|
		##|  Make a reference to the columns by number
		colNum = 0
		@colByNum = {}
		for i in @colList
			if !i.visible then continue
			i.colNum = colNum++
			@colByNum[i.colNum] = i

		@layoutShadow()
		@updateVisibleText()
		@elTableHolder.append tableWrapper.el
		@internalSetupMouseEvents()

		setTimeout () =>
			# globalResizeScrollable();
			if setupSimpleTooltips?
				setupSimpleTooltips();
		, 1

		##|
		##|  This is a new render which means we need to re-establish any context menu
		@contextMenuCallSetup = 0

		##|
		##|  Setup context menu on the header
		# @setupContextMenu @contextMenuCallbackFunction

		##| add default context menu for sorting as per #89 comment
		# @setupContextMenu @contextMenuCallbackFunction
		true


	## -------------------------------------------------------------------------------------------------------------
	## function to sort the table base on column and type
	##
	## @param [String] name name of the column to apply sorting on
	## @param [String] type it can be ASC|DESC
	##
	sortByColumn: (name) =>

		for col in @colList
			if col.getSource() == name
				if col.sort == -1
					col.UpdateSortIcon(1)
				else if col.sort == 1
					col.UpdateSortIcon(0)
				else
					col.UpdateSortIcon(-1)

		@internalApplySorting()
		true

	##|
	##|  Add a group by condition
	groupBy: (columnSource) =>

		for name in @currentGroups
			if name == columnSource then return

		@currentGroups.push columnSource

		for col in @colList
			if col.getSource() in @currentGroups
				col.isGrouped = true
			else
				col.isGrouped = false

		@updateRowData()
		return


	## -------------------------------------------------------------------------------------------------------------
	## intenal event key press in a filter field, that executes during the filter text box keypress event
	##
	## @event onFilterKeypress
	## @param [Event] e jquery event keypress object
	## @return [Boolean]
	##
	onFilterKeypress: (e) =>

		parts      = e.path.split '/'
		tableName  = parts[1]
		keyValue   = parts[2]
		columnName = parts[3]

		if !@currentFilters[tableName]?
			@currentFilters[tableName] = {}

		@currentFilters[tableName][columnName] = $(e.target).val()
		console.log "Current filter:", @currentFilters
		@updateRowData()
		@updateVisibleText()

		return true

	## -------------------------------------------------------------------------------------------------------------
	## add a row that takes the full width using colspan
	##
	## @param [String] message the message that should be displayed in column
	##
	addMessageRow : (message) =>
		@rowDataRaw.push message
		return 0;

	## -------------------------------------------------------------------------------------------------------------
	## clear the table using jquery .html ""
	##
	clear : =>
		@elTableHolder.html ""

	## -------------------------------------------------------------------------------------------------------------
	## clear the html and also remove the associated column and rows reference
	##
	reset: () =>
		@elTableHolder.html ""
		@colList = []
		true

	## -------------------------------------------------------------------------------------------------------------
	##|
	##|  Called when an even has been added using the event manager
	onAddedEvent: (eventName, callback)=>

		m = eventName.match /click_(.*)/
		if m? and m[1]?
			##|
			##|  Added a click event to a column named m[1]
			##|
			$(".col_#{m[1]}").css "cursor", "pointer"
			$(".col_#{m[1]}").addClass "clickable"

		true

	moveCellRight: ()=>
		if !@currentFocusCol? then return
		console.log "moveCellRight focus=", @currentFocusCol, " offset=", @offsetShowingLeft

		visCol = @getTableVisibleCols()
		maxCol = @getTableTotalCols()
		if @offsetShowingLeft + visCol + 1 < maxCol
			console.log "Able to move right"
			@scrollRight(1)
			@setFocusCell(@currentFocusRow, @currentFocusCol)
			return

		if @currentFocusCol + 1 >= @getTableVisibleCols()
			console.log "col=@currentFocusCol, scrolling"
			@scrollRight(1)
			@setFocusCell(@currentFocusRow, @currentFocusCol)
			return

		@setFocusCell(@currentFocusRow, @currentFocusCol+1)
		true

	moveCellLeft: ()=>
		if !@currentFocusCol? then return
		console.log "moveCellLeft focus=", @currentFocusCol, " offset=", @offsetShowingLeft

		if @offsetShowingLeft > 0
			@scrollRight(-1)
			@setFocusCell(@currentFocusRow, @currentFocusCol)
			return

		if @currentFocusCol == 0
			return

		@setFocusCell(@currentFocusRow, @currentFocusCol-1)
		true

	moveCellUp: ()=>

		if !@currentFocusRow? then return

		if @offsetShowingTop > 0
			@scrollUp(-1)
			@setFocusCell(@currentFocusRow, @currentFocusCol)
			return

		if @currentFocusRow == 0
			@scrollUp(-1)
			@setFocusCell(@currentFocusRow, @currentFocusCol)
			return

		@setFocusCell(@currentFocusRow-1, @currentFocusCol)
		true

	moveCellDown: ()=>

		if !@currentFocusRow? then return

		visRow = @getTableVisibleRows()
		maxRow = @getTableTotalRows()
		if @offsetShowingTop + visRow + 1 < maxRow
			@scrollUp(1)
			@setFocusCell(@currentFocusRow, @currentFocusCol)
			return

		if @currentFocusRow+1 >= @getTableVisibleRows()
			@scrollUp(1)
			@setFocusCell(@currentFocusRow, @currentFocusCol)
			return

		@setFocusCell(@currentFocusRow+1, @currentFocusCol)
		true

	##|
	##|  Auto select the first visible cell
	setFocusFirstCell: ()=>

		@setFocusCell(0,0)
		true

	##|
	##|  Focus on a path cell
	setFocusCell: (visibleRow, visColNum) =>

		if !@allowSelectCell
			return false

		cellType = @getCellType { visibleRow: visibleRow, visibleCol: visColNum, rowNum: null, colNum: null }
		if !visibleRow? or !visColNum? or cellType != "data"
			return false

		##|
		##|  Remove old focus
		if @currentFocusCell?
			@currentFocusCell.removeClass "cellfocus"
			@currentFocusCell = null

		@currentFocusRow = visibleRow
		@currentFocusCol = visColNum

		if visibleRow == null or visColNum == null
			@currentFocusRow = null
			@currentFocusCol = null
			return

		@currentFocusCell = @shadowCells[visibleRow].children[visColNum]
		if @currentFocusCell?
			path = @currentFocusCell.getDataValue("path")

			@currentFocusCell.addClass "cellfocus"
			item = @findRowFromPath(path)
			@emitEvent 'focus_cell', [ path, item ]

		return true

	##|
	##|  Returns true if a path is visible
	findPathVisible: (path)=>

		for idx, shadow of @shadowCells
			for cell in shadow.children
				if cell.getDataValue("path") == path
					return cell

		return null


	## -------------------------------------------------------------------------------------------------------------
	## internal function to find the col name from the event object
	##
	## @param [Event] e the jquery Event object
	## @param [Integer] stackCount number of checking round
	##
	findColFromPath: (path) =>

		if !path? then return null
		parts     = path.split '/'
		tableName = parts[1]
		keyValue  = parts[2]
		colName   = parts[3]
		return colName

	## -------------------------------------------------------------------------------------------------------------
	## internal function to find the row element from the event object
	##
	## @param [Event] e the jquery Event object
	## @param [Integer] stackCount number of checking round
	##
	findRowFromPath: (path) =>

		if !path? then return null
		parts     = path.split '/'
		tableName = parts[1]
		keyValue  = parts[2]
		colName   = parts[3]

		if keyValue == "Filter"
			return "Filter"

		if keyValue == "Header"
			@sortByColumn colName
			return "Header"

		data = {}
		colNum = 0
		for col in @colList

			fieldName = col.getSource()
			fieldValue = DataMap.getDataField col.tableName, keyValue, fieldName
			data[fieldName] = fieldValue

		data["id"] = keyValue
		return data
