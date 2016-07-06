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

	##|
	##| ******************************[ Get certain properties and information from table ]*************************
	##|

	## -------------------------------------------------------------------------------------------------------------
	## get the count of rows inside the table
	##
	## @return [Integer] the total number of rows
	##
	size : () =>
		return @rowData.length

	## -------------------------------------------------------------------------------------------------------------
	## returns the numbe of rows checked
	##
	## @return [Integer] no of rows checked in current table
	##
	numberChecked: () =>
		total = 0
		for i, o of @rowData
			if o.checked then total++
		total

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
		@rowData        = []

		# @property [Boolean|Function] sorting function to apply on render
		@sort           = 0

		# @property [Boolean] to show headers of table
		@showHeaders    = true

		# @property [Boolean] to show textbox to filter data
		@showFilters	= true

		# @property [Object] currentFilters current applied filters to the table
		@currentFilters  = {}

		# @property [Object] rowDataElements data rows in the table
		@rowDataElements = {}

		# @property [Boolean|Function] callback to call on context menu click
		@contextMenuCallbackFunction = 0

		# @property [Boolean|Function] add menu to context menu
		@contextMenuCallSetup        = 0

		# @property [Boolean] showCheckboxes if checkbox to be shown or not default false
		if !@showCheckboxes?
			@showCheckboxes = false

		if (!@elTableHolder[0])
			console.log "Error: Table id #{@elTableHolder} doesn't exist"

		# @property [Object] current table configurations
		@tableConfig = {}

		#@property [Object] table database configuration
		@tableConfigDatabase = null

		#@property [int] the offset from the top to start showing
		@offsetShowingTop = 0

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
	## Table cache name is set, this allows saving/loading table configuration
	##
	## @param [String] tableCacheName the cache name to attach with table
	##
	setTableCacheName: (@tableCacheName) =>

	## -------------------------------------------------------------------------------------------------------------
	## add custom filter function which will be called on the key press of filter field
	##
	## @param [Function] filterFunction to be called in keypress
	##
	setFilterFunction: (filterFunction) =>

		@filterFunction = filterFunction

		##|
		##|  Force the table to redraw with a global "redrawTables" command
		GlobalValueManager.Watch "redrawTables", () =>
			@applyFilters()

	## -------------------------------------------------------------------------------------------------------------
	## make the table with fixed header and scrollable
	##
	## @param [Boolean] fixedHeader if header is fixed or not
	##
	setFixedHeaderAndScrollable: (@fixedHeader = true) =>
		$(window).on 'resize', () =>
			@elTableHolder.find('.table-header .tableview').width(@elTableHolder.find('.table-body .tableview').width())

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
	resetChecked : (bookmarkArray) =>

		for i, o of @rowData
			o.checked = false
			for x, y of bookmarkArray
				if y.id == o.checkbox_key
					o.checked = true

			key = o.id
			if o.checked
				$("#check_#{@gid}_#{key}").html @imgChecked
			else
				$("#check_#{@gid}_#{key}").html @imgNotChecked

		false

	scrollUp: (amount)=>

		@offsetShowingTop += amount

		if @offsetShowingTop + @shadowRows.length > @rowData.length
			@offsetShowingTop = @rowData.length - @shadowRows.length

		if @offsetShowingTop < 0
			@offsetShowingTop = 0

		@updateVisibleText()

		##|
		##|  Set the vertical scroll position
		@virtualScrollV.setPos @offsetShowingTop
		true

	scrollRight: (amount)=>

		if amount < 0 then amount = 0
		if amount + @virtualScrollH.width > @virtualScrollH.max
			amount = @virtualScrollH.max - @virtualScrollH.width

		console.log "SETTING LEFT:", amount * -1

		@elTheTable.el.css "left", -1 * amount
		@virtualScrollH.setPos amount
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

			##|
			##|  Use the new event manager
			@emitEvent "click_#{col}", [ data, e ]

			for c in @colList
				if c.getSource() == col
					if c.getEditable()
						console.log "EDIT:", data, e
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

		console.log "Apply sorting"

		@rowData.sort (a, b)=>

			for c in @colList

				if c.sort? and c.sort == 1
					if a[c.getSource()] < b[c.getSource()] then return 1
					if a[c.getSource()] > b[c.getSource()] then return -1

				else if c.sort? and c.sort == -1
					if a[c.getSource()] < b[c.getSource()] then return -1
					if a[c.getSource()] > b[c.getSource()] then return 1

			return 0

		@updateVisibleText()

		true

	## -------------------------------------------------------------------------------------------------------------
	## function to update row data on the screen if new data has been added in datamapper they can be considered
	##
	updateRowData: () =>

		@rowData = []
		@rowDataRaw = []

		# for col in @colList
			# console.log "COL=", col

		allData = DataMap.getValuesFromTable @primaryTableName, @reduceFunction
		for keyName, obj of allData

			obj.visible = true

			objRaw = {}
			colNum = 0
			for col in @colList

				if !col.visible
					continue

				if col.joinKey?
					val = DataMap.getDataField col.joinTable, obj.id, col.joinKey
					obj[col.getSource()] = DataMap.getDataFieldFormatted col.tableName, val, col.getSource()
					objRaw[col.getSource()] = DataMap.getDataField col.tableName, val, col.getSource()
				else
					obj[col.getSource()] = DataMap.getDataFieldFormatted col.tableName, obj.id, col.getSource()
					objRaw[col.getSource()] = DataMap.getDataField col.tableName, obj.id, col.getSource()

				colNum++

			##|
			##|  Values for the bookmark / selected checkbox
			obj.row_selected = @imgNotChecked
			objRaw.row_selected = false

			# console.log "ADDING ROW", obj
			@rowData.push obj
			@rowDataRaw.push objRaw

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
	## internal function to calculate the number of occurences for each value in options
	##
	## @param [Object] col the whole column object
	## @param [Boolean] initialize if table has been rendered or not
	##
	internalCountNumberOfOccurenceOfPopup: (col,initialize = false) =>

		##| calculate occurances of unique values
		occurences = @rowData.map (r) => {key: r.id, value : DataMap.getDataField col.tableName, r.id, col.getSource()}
		counts = {}
		occurences.forEach (v) =>
			if $("#tbody#{@gid}").find("[data-id=#{v.id}]").is(":visible") or initialize
				if counts[v.value] then counts[v.value]++ else counts[v.value] = 1
		occurences = undefined
		col.filterPopupData = counts

		if @filterAsPopupCols and typeof @filterAsPopupCols == 'object'
			@filterAsPopupCols[col.getSource()] = col
		else
			@filterAsPopupCols =
				"#{col.getSource()}" : col

	## -------------------------------------------------------------------------------------------------------------
	## function to make column customizable in the popup
	##
	## @example
	##		table.allowCustomize()
	## @param [Boolean] customizableColumns
	##
	allowCustomize: (@customizableColumns = true) ->

	updateVisibleText: ()=>

		if @offsetShowingTop < 0
			@offsetShowingTop = 0

		rowNum       = @offsetShowingTop
		shadowRowNum = 0

		while shadowRowNum < @shadowRows.length

			row = @shadowRows[shadowRowNum]

			if rowNum >= @rowData.length
				##|
				##|  Special case, no values left to show
				colNum = 0
				for col in @colList
					if !col.visible then continue
					row[colNum].text ""
					row[colNum].removeClass "dataChanged"
					row[colNum].setDataPath ""
					colNum++

				shadowRowNum++
				continue

			if @rowData[rowNum].visible? and not @rowData[rowNum].visible
				rowNum++
				continue

			colNum = 0
			for col in @colList
				if !col.visible
					continue

				row[colNum].html @rowData[rowNum][col.getSource()]
				row[colNum].removeClass "dataChanged"
				row[colNum].setDataPath "/#{col.tableName}/#{@rowData[rowNum].id}/#{col.getSource()}"
				colNum++

			rowNum++
			shadowRowNum++

		strStatus = "Showing " + (@offsetShowingTop+1) + " - " + (rowNum) + " of " + @rowData.length
		true

	getMaxVisibleRows: ()=>

		##|
		##|  Determine how many rows are visible based on scroll area.   If it's not scrollable then
		##|  all rows are visible

		if not @fixedHeader
			return @rowData.length

		maxHeight  = @elTableHolder.height()

		##|
		##|  Remove space for bottom scrollbar
		maxHeight -= @virtualScrollH.height

		if @showFilters
			maxHeight -= @filterCellHeight

		if @showHeaders
			maxHeight -= @headerCellHeight

		##|
		##|  Should we account for headers / filters and scroll area?
		maxRows = maxHeight / @dataCellHeight
		# console.log "Height=", maxHeight, " MaxRows=", maxRows
		return Math.ceil(maxRows)

	layoutShadow: ()=>

		maxWidth   = @elTableHolder.width()
		maxHeight  = @elTableHolder.height()

		##|
		##|  If the horizontal scrollbar is showing then don't
		##|  let the vertical go all the way to the bottom
		##|
		if @virtualScrollH.visible
			@virtualScrollV.bottomPadding = @virtualScrollH.height-1

		if !@fixedHeader
			@virtualScrollV.hide()
			@virtualScrollH.hide()
		else
			@virtualScrollV.resize()
			@virtualScrollH.resize()

		##|
		##|  Max room for the scrollbars
		maxWidth -= @virtualScrollV.width

		##|
		##|  Look at all the columns, determine the likely width
		widthLimit   = maxWidth
		missingCount = 0
		colNum       = 0

		for i in @colList
			calcWidth = i.calculateWidth()
			if not i.visible
				i.actualWidth = -1
			else

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

			if x == colNum-1 and !i.actualWidth?
				i.actualWidth = widthLimit - totalWidth
				if i.actualWidth < 60
					i.actualWidth = 60

			if !i.actualWidth?
				i.actualWidth = unallocatedSpace

			totalWidth += i.actualWidth
			# console.log "COL ", i.getSource(), " = ", i.actualWidth, " [", totalWidth, "]"

		# console.log "Actual=", widthLimit, "Total Width = ", totalWidth

		##|
		##|  Remove or add a pixel until we have the exact amount
		##|  but only if we are smaller than available size or very close to it
		if totalWidth - 50 < widthLimit
			while totalWidth != widthLimit

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

		if @fixedHeader
			##|
			##|  Set the scrollbar range on the hscroll
			setTimeout ()=>

				if totalWidth == widthLimit
					@virtualScrollH.hide()
				else
					@virtualScrollH.setRange 0, totalWidth, widthLimit
					@virtualScrollH.setPos 0

				@virtualScrollV.setRange 0, @rowData.length, @shadowRows.length
				@virtualScrollV.setPos 0

			, 10

			@elTheTable.el.width totalWidth

		x = 0
		y = 0

		drawRow = (rowList, rowHeight, dataPathPrefix)=>

			colNum = 0
			x      = 0
			for i in @colList
				if not i.visible then continue
				cell = rowList[colNum]
				cell.move x, y, i.actualWidth, rowHeight
				x += i.actualWidth
				colNum++

			y += rowHeight
			true


		##|
		##|  Place the header rows
		if @showHeaders
			drawRow @shadowHeader, @headerCellHeight, "Header"

		##|
		##|  Place the filter rows
		if @showFilters
			drawRow @shadowFilter, @filterCellHeight, "Filter"

		##|
		##|  Place the data cells
		for row in @shadowRows
			drawRow row, @dataCellHeight, "last"

		if !@fixedHeader or maxHeight == 0
			@elTableHolder.height(y)

		true

	## -------------------------------------------------------------------------------------------------------------
	## function to render the added table inside the table holder element
	##
	## @example tableview.render()
	## @return [Boolean]
	##
	render: () =>

		##|
		##|  Get the data from that table
		@updateRowData()
		@rowDataElements = {}

		##|
		##|  Create a unique ID for the table, that doesn't change
		##|  even if the table is re-drawn
		if !@gid?
			@gid = GlobalValueManager.NextGlobalID()

		html = "";

		@elTableHolder.html("")
		@widgetBase = new WidgetBase()

		tableWrapper   = @widgetBase.addDiv "table-wrapper", "tableWrapper#{@gid}"
		outerContainer = tableWrapper.addDiv "outer-container"
		@elTheTable    = outerContainer.addDiv "inner-container tableview"

		@virtualScrollV = new VirtualScrollArea outerContainer, true
		@virtualScrollH = new VirtualScrollArea outerContainer, false

		@shadowHeader  = []
		@shadowFilter  = []
		@shadowRows    = []

		##|  Add headers
		if @showHeaders

			for i in @colList
				if !i.visible then continue
				@shadowHeader.push i.RenderHeader(i.extraClassName, @elTheTable)

		if @showFilters

			for i in @colList
				if !i.visible then continue
				tag = @elTheTable.addDiv 'dataFilterWrapper'
				filter = tag.add "input", "dataFilter #{i.getFormatterName()}"
				filter.setDataPath "/#{i.tableName}/Filter/#{i.getSource()}"
				filter.bind "keyup", @onFilterKeypress
				@shadowFilter.push tag

		##| if no row found then default message
		if @rowData.length is 0
			console.log "TODO: Add empty results"
			@addMessageRow "No results"

		##|
		##| TODO CHECK FOR FILTER

		maxRows = @getMaxVisibleRows()
		if maxRows > @rowData.length
			@virtualScrollV.hide()
			maxRows = @rowData.length

		for rowNum in [0...maxRows]

			row = []
			for i in @colList
				if !i.visible then continue

				editable = ""
				if i.getEditable() then editable = " editable"
				if rowNum % 2 == 0 then editable += " even"
				if i.getAlign() == "right" then editable += " text-right"
				if i.getAlign() == "center" then editable += " text-center"
				editable += " col_" + i.getSource()
				colTag = @elTheTable.addDiv "#{i.getFormatterName()} #{editable}"
				colTag.text "r=#{rowNum},#{i.getSource()}"
				row.push colTag

			@shadowRows.push row

		@layoutShadow()
		@updateVisibleText()
		@internalSetupMouseEvents()
		@elTableHolder.append tableWrapper.el
		return

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
		@setupContextMenu @contextMenuCallbackFunction

		##| add default context menu for sorting as per #89 comment
		@setupContextMenu @contextMenuCallbackFunction
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
				else
					col.UpdateSortIcon(-1)

		@internalApplySorting()
		true


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
		console.log "VAL=", @currentFilters[tableName]
		@applyFilters()

		return true

	## -------------------------------------------------------------------------------------------------------------
	## internal event handler for selected filter popup values
	##
	## @event onFilterPopupClick
	## @param [Event] e jquery event object
	##
	onFilterPopupClick: (e) =>
		source = $(e.target).data('source')
		if @filterAsPopupCols[source]
			options = @filterAsPopupCols[source].filterPopupData
			menu = new PopupMenu("Filter", e);

			if !@currentFilters[@filterAsPopupCols[source].tableName]?
				@currentFilters[@filterAsPopupCols[source].tableName] = {}

			Object.keys(options).forEach (option) =>
				menu.addItem "<div style='padding-left:10px;padding-right:10px;'>#{option}   <div class='badge pull-right' style='margin-top:12px;'> #{options[option]} </div></div>", (data) =>
					@currentFilters[@filterAsPopupCols[source].tableName][@filterAsPopupCols[source].getSource()] = option
					$(e.target).find('.filtered_text').text option
					@applyFilters()

			menu.addItem "Clear filter", (data) =>
				delete @currentFilters[@filterAsPopupCols[source].tableName][@filterAsPopupCols[source].getSource()]
				$(e.target).find('.filtered_text').text 'select'
				@applyFilters()

	## -------------------------------------------------------------------------------------------------------------
	## Apply filters stored in "currentFilters" to each column and show/hide the rows
	##
	applyFilters: () =>

		##|
		##| Build the filters

		filters = []
		for tableName, fieldList of @currentFilters
			for fieldName, filterValue of fieldList
				filters.push
					keyName: fieldName
					filter : new RegExp filterValue, "i"

		rowNum  = 0
		needRefresh = false
		for row in @rowData

			if !row.visible?
				row.visible = true

			##|
			##| Each row has the element (el) and the children TD nodes in children

			keepRow = true
			for f in filters
				if not keepRow then continue
				if not f.filter.test row[f.keyName]
					keepRow = false

			if keepRow and not row.visible
				row.visible = true
				needRefresh = true
			else if not keepRow and row.visible
				row.visible = false
				needRefresh = true

		if needRefresh
			@updateVisibleText()

		return


		##|
		##| TODO:  Check for new rows being added, but not here.
		##| it should be done in a manually called function such as updateRowData?
		##|
		# if (@rowData.length != DataMap.getValuesFromTable(@primaryTableName).length)
		# 	previousRowsCount = @rowData.length
		# 	@updateRowData()

		##
		##  TODO:
		##  Re-add the new row effect except here isn't the right place
		##  it takes too long to check for new rows every time you press a key in the filter

		# removeNewRowClass = (html) =>
		# 	setTimeout () =>
		# 		key = $(html).data 'id'
		# 		@elTheTable.find("tr[data-id=#{key}]").removeClass 'newDataRow'
		# 	,3000

		# ##| if row is not present for that data, render new row
		# if !@elTheTable.find("tr [data-path^='/#{@primaryTableName}/#{i.id}/']").length
		# 	html = @internalRenderRow(previousRowsCount,i,true)
		# 	@elTheTable.find('tbody').prepend(html)
		# 	removeNewRowClass html
		# 	previousRowsCount++


		popupCols = []
		if typeof @filterAsPopupCols is 'object' then popupCols = Object.keys @filterAsPopupCols
		popupCols.forEach (columnObj) =>
			column = @colList.filter (c) => c.getSource() == columnObj
			column = column.pop()
			@internalCountNumberOfOccurenceOfPopup column

		true

	## -------------------------------------------------------------------------------------------------------------
	## add a row that takes the full width using colspan
	##
	## @param [String] message the message that should be displayed in column
	##
	addMessageRow : (message) =>
		@rowData.push message
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
		@rowData = []
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
