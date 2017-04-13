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

globalKeyboardEvents    = new EvEmitter()
globalTableEvents       = new EvEmitter()
globalTableAdmin        = true
minHeightOfTable        = 400

$(window).on "resize", (e)=>
	w = $(window).width()
	h = $(window).height()
	globalTableEvents.emitEvent "resize", [w, h]

$(document).on "keyup", (e)=>

	if e.target == document.body
		if e.keyCode == 38
			# console.log "DOC KEY [up]"
			globalKeyboardEvents.emitEvent "up", [e]
		else if e.keyCode == 40
			# console.log "DOC KEY [down]"
			globalKeyboardEvents.emitEvent "down", [e]
		else if e.keyCode == 37
			# console.log "DOC KEY [left]"
			globalKeyboardEvents.emitEvent "left", [e]
		else if e.keyCode == 39
			# console.log "DOC KEY [right]"
			globalKeyboardEvents.emitEvent "right", [e]
		else if e.keyCode == 9
			# console.log "DOC KEY [tab]"
			globalKeyboardEvents.emitEvent "tab", [e]
		else if e.keyCode == 13
			# console.log "DOC KEY [enter]"
			globalKeyboardEvents.emitEvent "enter", [e]
		else if e.keyCode == 27
			# console.log "DOC KEY [esc]"
			globalKeyboardEvents.emitEvent "esc", [e]

	return true

$(document).on "mousedown", (e)=>
	globalKeyboardEvents.emitEvent "global_mouse_down", [ e ]
	return true

class TableView

	@SORT_ASC  : 1
	@SORT_DESC : -1
	@SORT_NONE : 0

	# @property [String] imgChecked html to be used when checkbox is checked
	imgChecked     : "<img src='/images/checkbox.png' width='16' height='16' alt='Selected' />"

	# @property [String] imgNotChecked html to be used when checkbox is not checked
	imgNotChecked  : "<img src='/images/checkbox_no.png' width='16' height='16' alt='Selected' />"

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

		GlobalClassTools.addEventManager(this)

		# @property [Array] list of columns as array
		@colList           = []
		@actionColList     = []

		# @property [Array] list of rows as array
		@rowDataRaw      = []
		@rowDataSelected = {}

		# @property [Boolean] to show headers of table
		@showHeaders    = true

		# @property [Boolean] to show textbox to filter data
		@showFilters     = true
		@allowSelectCell = true
		@showResize      = true
		@showConfigTable = true
		@enableMouseOver = false

		# @property [Object] currentFilters current applied filters to the table
		@currentFilters    = {}
		@currentGroups     = []
		@sortRules         = []
		@lockList          = {}
		@showGroupPadding  = false
		@groupPaddingWidth = 10

		# @property [Boolean|Function] callback to call on context menu click
		@contextMenuCallbackFunction = 0

		# @property [Boolean|Function] add menu to context menu
		@contextMenuCallSetup        = 0

		# @property [int] the max number of rows that can be selected
		@checkboxLimit = 1

		@renderRequired = true

		# @property [Boolean] showCheckboxes if checkbox to be shown or not default false
		if !@showCheckboxes? then @showCheckboxes = false

		if (!@elTableHolder[0])
			console.log "Error: Table id #{@elTableHolder} doesn't exist for #{@primaryTableName}"
			return

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
		@on "added_event", @onAddedEvent

		globalKeyboardEvents.on "up", @moveCellUp
		globalKeyboardEvents.on "down", @moveCellDown
		globalKeyboardEvents.on "left", @moveCellLeft
		globalKeyboardEvents.on "right", @moveCellRight
		globalKeyboardEvents.on "tab", @moveCellRight
		globalKeyboardEvents.on "enter", @pressEnter
		globalKeyboardEvents.on "global_mouse_down", @onGlobalMouseDown
		globalKeyboardEvents.on "change", @onGlobalDataChange
		globalTableEvents.on "table_change", @onGlobalTableChange
		globalTableEvents.on "resize", @onResize
		window.addEventListener "new_data", @onGlobalNewData, false

		##|
		##|  Create a unique ID for the table, that doesn't change
		##|  even if the table is re-drawn
		if !@gid?
			@gid = GlobalValueManager.NextGlobalID()

	## -------------------------------------------------------------------------------------------------------------
	## to add the table in the view from datamap
	##
	## @example tableView.addTable "zipcode"
	## @param [String] tableName name of the table to consider from datamap
	## @param [Function] columnReduceFunction will be applied to each row and each column and if returns true then only column will be included
	## @param [Function] reduceFunction will be applied to each row and if returns true then only row will be included
	## @return [Boolean]
	##
	addTable: (tableName, @columnReduceFunction, @overallReduceFunction) =>
		@primaryTableName = tableName
		true

	##|
	##| Return a column from source name
	findColumn: (source)=>

		for c in @colList
			if c.getSource() == source
				return c

	##|-------------------------------------------------------------------------------------------------------------
	##| Convert one of the columns into an action column
	##|
	moveActionColumn: (sourceName)=>

		found   = false
		newList = []

		columns = DataMap.getColumnsFromTable(@primaryTableName, null)
		for col in columns
			if col.getSource() == sourceName
				@actionColList.push col
				#@actionColList.push Object.assign(Object.create(col), col)

		return true

	##|-------------------------------------------------------------------------------------------------------------
	##| Add a column to the end of the table
	##|
	addActionColumn: (options)=>

		config    =
			name      : ""
			render    : null
			width     : 100
			callback  : null
			source    : null
			tableName : @primaryTableName

		$.extend config, options

		console.log "AddActionColumn:", config

		button = new TableViewColButton(@primaryTableName, config.name)
		button.width       = config.width
		button.actualWidth = config.width
		if config.render?
			# console.log "Setting render", button
			button.render = config.render

		button.source = config.source
		@actionColList.push button
		if config.callback?
			@on "click_#{button.getSource()}", config.callback

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

	setFixedSize: (w, h)=>

		@fixedWidth  = w
		@fixedHeight = h
		@showFilters = false
		@fixedHeight = true
		@showHeaders = true
		@elTableHolder.width(w)
		@elTableHolder.height(h)
		@elTableHolder.find('.table-header .tableview').width(@elTableHolder.find('.table-body .tableview').width())
		@resetCachedFromSize()

	## -------------------------------------------------------------------------------------------------------------
	## make the table with fixed header and scrollable
	##
	## @param [Boolean] fixedHeader if header is fixed or not
	##
	setFixedHeaderAndScrollable: (@fixedHeader = true) =>

		$(window).on 'resize', () =>
			@elTableHolder.find('.table-header .tableview').width(@elTableHolder.find('.table-body .tableview').width())
			@cachedVisibleWidth  = null
			@cachedVisibleHeight = null

	## -------------------------------------------------------------------------------------------------------------
	onClickSimpleObject: (row, e)=>
		coords    = GlobalValueManager.GetCoordsFromEvent(e)
		data =  $(e.target).data()
		if data.path?
			@openSimpleObject(data.path)
		true

	##|
	##|  Open a popup view of a simple object
	openSimpleObject: (path, coords)=>

		coords    = GlobalValueManager.GetCoordsFromEvent(e)

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

	getRowLocked: (id)=>
		if @lockList[id]? then return true
		return false

	##|
	##| Toggle a row as selected/not selected
	toggleRowSelected: (row) =>

		if @getRowLocked(row.id) then return false

		val = @getRowSelected row.id
		newVal = val == false

		if val

			globalTableEvents.emitEvent "row_selected", [ @primaryTableName, row.id, false ]

			row.row_selected = false
			DataMap.getDataMap().updatePathValueEvent "/#{@primaryTableName}/#{row.id}/row_selected", false
			delete @rowDataSelected[row.id]

		else

			if @checkboxLimit == 1
				for id in Object.keys(@rowDataSelected)
					globalTableEvents.emitEvent "row_selected", [ @primaryTableName, row.id, false ]
					DataMap.getDataMap().updatePathValueEvent "/#{@primaryTableName}/#{id}/row_selected", false

				@rowDataSelected = {}

			console.log "Setting /#{@primaryTableName}/#{row.id}/row_selected = true"
			DataMap.getDataMap().updatePathValueEvent "/#{@primaryTableName}/#{row.id}/row_selected", true
			globalTableEvents.emitEvent "row_selected", [ @primaryTableName, row.id, true ]
			@rowDataSelected[row.id] = true

		@resetChecked()
		# @updateVisibleText()
		true

	scrollUp: (amount)=>
		@offsetShowingTop += amount
		@resetCachedFromScroll()
		true

	scrollRight: (amount)=>
		@offsetShowingLeft += amount
		@resetCachedFromSize()
		true

	##|
	##|  New data from the server
	onGlobalNewData: (e)=>

		# console.log "table #{@gid} onGlobalNewData e=", e
		if !e? or e.detail.tablename == @primaryTableName
			# @resetCachedFromSize()
			if @resetTimer?
				clearTimeout(@resetTimer)

			@resetTimer = setTimeout ()=>
				delete @resetTimer
				## 3.27
				@updateRowData()
				##
				@resetCachedFromSize()
				@onResize()
			, 50

	##|
	##|  Event triggered when any tableview has a column change
	##|  so that we can see if we need to update the view
	onGlobalTableChange: (tableName, sourceName, field, newValue)=>

		if tableName == @primaryTableName
			@onGlobalNewData(null)

		true

	onGlobalDataChange: (path, newData)=>
		##|
		##|  Something globally change the value of a path, see if we care
		# console.log "tableView onGlobalDataChange path=#{path}"
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

	##|
	##|  Set a column's filter to show a popup instead of clear typing
	setColumnFilterAsPopup: (sourceName)=>

	pressEnter: (e)=>

		# console.log "pressEnter cell=", @currentFocusCell, "path=", @currentFocusPath

		if @currentFocusCell? and !@currentFocusPath?
			##|
			##|  Likely due to an open editor so now reset focus
			@setFocusCell(@currentFocusRow, @currentFocusCol, e)
			return false

		if !@currentFocusCell? or !@currentFocusPath?
			return false

		if e.path? then @currentFocusPath = e.path
		parts     = @currentFocusPath.split "/"
		tableName = parts[1]
		record_id = parts[2]
		fieldName = parts[3]
		path      = @currentFocusPath

		for row in @rowDataRaw
			if not row.id? then continue
			if row.id.toString() == record_id

				for c in @colList
					row[c.getSource()] = DataMap.getDataField c.tableName, row.id, c.getSource()
					if c.getSource() == fieldName
						if c.getEditable()
							@currentFocusPath = null
							DataMap.getDataMap().editValue path, @currentFocusCell.el

				##|  Use the new event manager
				@emitEvent "click_#{fieldName}", [ row, e ]
				@emitEvent "click_row", [ row, e ]

		true

	onColumnResizeDrag: (diffX, diffY, e)=>

		##|
		##|  Locally and temporary change width
		##|

		source = @colByNum[@resizingColumn].getSource()
		col    = @findColumn(source)
		newWidth = @resizingBefore + diffX
		if newWidth < 10 then newWidth = 10
		if newWidth > 800 then newWidth = 800
		col.changeColumn("width", newWidth)
		@resetCachedFromSize()
		@updateVisibleText()

		# @setCustomWidth(@resizingRow, @resizingColumn, @resizingBefore + diffX)
		true

	onColumnResizeFinished: (diffX, diffY, e)=>

		source = @colByNum[@resizingColumn].getSource()
		col    = @findColumn(source)
		newWidth = @resizingBefore + diffX
		if newWidth < 10 then newWidth = 10
		if newWidth > 800 then newWidth = 800

		DataMap.changeColumnAttribute col.tableName, col.getSource(), "width", newWidth
		delete @resizingColumn
		true

	onMouseHover: (e)=>
		coords = GlobalValueManager.GetCoordsFromEvent(e)
		if !e.path?
			@tooltipWindow.hide()
			return

		@tooltipShowing = false
		row  = @findRowFromPath e.path
		col  = @findColFromPath e.path

		for c in @colList
			if c.getSource() == col
				w = @tooltipWindow.getBodyWidget()
				w.resetClasses "ninjaTooltipBody"
				@tooltipWindow.floatingWin.addClass "ninjaTooltip"

				if row? and row[col]?
					result = c.renderTooltip(row, row[col], @tooltipWindow)
					console.log "RESULT=", result, c
					if result == true
						@tooltipWindow.moveTo(coords.x - (@tooltipWindow.width/2), coords.y - 10 - @tooltipWindow.height)
						@tooltipWindow.show()
						@tooltipShowing = true

		# console.log "HOVER:", e.path, coords, "col=", col, "row=", row

	onMouseOut: (e)=>

		if @lastMouseMovePath? and @enableMouseOver
			@lastMouseMovePath = null
			globalTableEvents.emitEvent "mouseover", [ @primaryTableName, null, null, null ]

		if @mouseHoverTimer?
			clearTimeout @mouseHoverTimer
			delete @mouseHoverTimer

		if @tooltipShowing? and @tooltipShowing == true
			@tooltipShowing = false
			@tooltipWindow.hide()

		true

	onMouseMove: (e)=>

		if e? and e.path? and @enableMouseOver
			##|
			##|  If mouseover events are enabled
			##|  Emit the event as Table Name, Path, Row Data, col
			##|
			if e.path != @lastMouseMovePath
				row = @findRowFromPath e.path
				col = @findColFromPath e.path
				globalTableEvents.emitEvent "mouseover", [ @primaryTableName, e.path, row, col ]
				@lastMouseMovePath = e.path

		if @mouseHoverTimer? then clearTimeout @mouseHoverTimer
		@mouseHoverTimer = setTimeout @onMouseHover, 1000, e
		if @tooltipShowing? and @tooltipShowing == true
			coords = GlobalValueManager.GetCoordsFromEvent(e)
			@tooltipWindow.moveTo(coords.x - (@tooltipWindow.width/2), coords.y - 10 - @tooltipWindow.height)

	## -------------------------------------------------------------------------------------------------------------
	## to setup event internally for the table
	##
	internalSetupMouseEvents: () =>

		@virtualScrollV.on "scroll_to", (amount)=>
			@offsetShowingTop = amount
			@updateScrollbarSettings()
			@resetCachedFromScroll()
			true

		@virtualScrollH.on "scroll_to", (amount)=>
			@offsetShowingLeft = amount
			@updateScrollbarSettings()
			@resetCachedFromScroll()
			true

		@elTheTable.on "mouseout", @onMouseOut

		@elTheTable.on "mousemove", @onMouseMove

		@elTheTable.on "mousedown", (e)=>

			##|
			##|  Let other tables know because this gives up focus on cells
			globalKeyboardEvents.emitEvent "global_mouse_down", [ e ]

			##|
			##|  Check for a resize start
			data = WidgetTag.getDataFromEvent e
			if data.path? and data.path == "grab"
				##|
				##|  Start resizing, save the location that was selected at the start
				@resizingColumn = data.cn
				@resizingRow    = data.rn
				@resizingBefore = @colByNum[data.cn].currentWidth
				return GlobalMouseDrag.startDrag(e, @onColumnResizeDrag, @onColumnResizeFinished)

			return false

		@elTheTable.on "click touchbegin", (e) =>

			if e.target.className == "dataFilter"
				console.log "passing"
				$(e.target).focus()
				return false

			data = WidgetTag.getDataFromEvent e
			console.log "elTheTable.on click data=", data

			if !data? or !data.path?
				console.log "No path for click", e.path
				return false

			row  = @findRowFromPath data.path
			col  = @findColFromPath data.path

			if row? and row.id?
				@setFocusCell(data.vr, data.vc, e)
			else
				@setFocusCell(null)

			if data.action?
				@elTheTable.el.trigger "click_#{data.action}", [row, e]

			if !row?
				return false

			if row == "Filter"
				##|
				##|  Don't do anything here for filter columns
				return false

			if row == "Header"
				##|
				##|  TODO: Add sorting here
				@sortByColumn col
				return false

			if col == "row_selected"
				##|
				##|  Toggle row selection
				@toggleRowSelected row
			else
				##|
				##|  Use the new event manager
				@pressEnter(e)

				##|
				##|  See if the cell has a focus function, which we
				##|  only call on mouse focus not keyboard
				realCol = @findColumn(col)
				if realCol? and realCol.onFocus? then realCol.onFocus(e, col, row)

			false

	onCopyToClipboard: (e, value)=>
		console.log "Copy to clipboard:", value
		copyToClipboard(value)
		true

	onContextMenuData: (e)=>

		data = WidgetTag.getDataFromEvent(e)
		row  = @findRowFromPath data.path
		col  = @findColFromPath data.path

		popupMenu = new PopupMenu "Options", e

		aValue = DataMap.getDataField @primaryTableName, row.id, col
		if aValue?
			aValue = aValue.toString().trim()
			popupMenu.addItem "Copy '#{aValue}'", @onCopyToClipboard, aValue

		bValue = DataMap.getDataFieldFormatted @primaryTableName, row.id, col
		if bValue? and bValue != aValue
			popupMenu.addItem "Copy '#{bValue}'", @onCopyToClipboard, bValue

		if @showCheckboxes and row.id?
			popupMenu.addItem "Copy '#{row.id}'", @onCopyToClipboard, row.id

		true

	##|
	##|  Called when context menu on a group row
	onContextMenuGroup: (rowNum, coords)=>
		popupMenu = new PopupMenu "Data Grouping", coords.x-150, coords.y

		##| add sorting menu item
		for source in @currentGroups
			popupMenu.addItem "Removing #{source}", (e, source) =>
				console.log "Remove grouping", source
				#col = @findColumn(source)
				#if col? then col.isGrouped = false
				@ungroupColumn source

				newList = []
				for name in @currentGroups
					if name == source then continue
					newList.push name

				@currentGroups = newList
				@updateRowData()
				@updateVisibleText()

			, source


		true

	onResize: ()=>
		if !@isVisible() then return

		@cachedVisibleWidth     = null
		@cachedVisibleHeight    = null
		@cachedTotalVisibleCols = null
		@cachedTotalVisibleRows = null

		if @fixedWidth? and @fixedHeight?
			@elTableHolder.width(@fixedWidth)
			@elTableHolder.height(@fixedHeight);
		else if @elTableHolder.width() > 0
			@updateFixedPosition()

		@updateRowData()
		true

	##|
	##|  Dialog to rename a column
	onRenameField: (source) =>

		for col in @colList
			if col.getSource() == source

				m = new ModalDialog
					showOnCreate: false
					content:      "Enter a new name for this column"
					position:     "top"
					title:        "Name:"
					ok:           "Save"

				m.getForm().addTextInput "input1", "Name", col.getName()
				m.getForm().onSubmit = (form) =>
					DataMap.changeColumnAttribute @primaryTableName, source, "name", form.input1
					@updateVisibleText()
					m.hide()

				m.show()

	contextMenuChangeType: (source, coords)=>

		popupMenu = new PopupMenu "New Type: #{source}", coords.x-150, coords.y-200
		for name in Object.keys(globalDataFormatter.formats)
			popupMenu.addItem name, (e, opt)=>
				console.log "Change type of #{source} to #{opt}"

				for col in @colList
					if col.getSource() == source
						DataMap.changeColumnAttribute col.tableName, source, "type", opt
						# @updateRowData()
						return

			, name

		true

	onRearrange: (e, source)=>

		##|
		##|  Open the re-arrange dialog
		m = new ModalSortItems(@primaryTableName);
		true

	onContextMenuHeader: (source, coords)=>

		console.log "Context on header:", source
		popupMenu = null

		for index, col of @colByNum
			if col.getSource() == source

				popupMenu = new PopupMenu "#{col.getName()}", coords.x-150, coords.y
				popupMenu.addItem "Hide column", (e, source)=>
					DataMap.changeColumnAttribute @primaryTableName, source, "visible", false
					# @setCustomVisible(source, false)
					@updateRowData()
				, source

				popupMenu.addItem "Group similar values", (e, source)=>
					@groupBy(source)
				, source

				popupMenu.addItem "Rearrange Columns", (e, source)=>
					@onRearrange(e, source)
				, source

				##|
				##|  Allow table to reconfigure
				if @showConfigTable

					popupMenu.addItem "Rename Column", (e, source)=>
						@onRenameField source
						@updateVisibleText()
					, source

					popupMenu.addItem "Change Column Type", (e, source)=>
						setTimeout ()=>
							@contextMenuChangeType source, coords
						, 500
					, source

					if globalTableAdmin
						popupMenu.addItem "Open table editor", (e, source)=>
							#for col in @colList
							for index, col of @colByNum
								if col.getSource() == source
									console.log "Emitting open_editor"
									# globalTableEvents.emitEvent "open_editor", [ col.tableName ]

									doPopupView "ShowTableEditor", "Editing table: #{@primaryTableName}", null, 1300, 800
									.then (view)=>
										view.showTableEditor @primaryTableName

						, source

		if popupMenu == null
			popupMenu = new PopupMenu "Unknown #{source}", coords.x-150, coords.y

		##|
		##|  Make a list of hidden columns that we can offer to unhide
		for col in @colList
			if col.visible? and col.visible == false
				popupMenu.addItem "Show #{col.getName()}", (e, list)=>
					showName = list.pop()
					source   = list.pop()
					num      = @findColumn(source).getOrder()
					DataMap.changeColumnAttribute col.tableName, showName, "visible", true
					DataMap.changeColumnAttribute col.tableName, showName, "order", num
					setTimeout ()=>
						@resetCachedFromSize()
						@updateVisibleText()
					, 200
				, [source, col.getSource()]


		false


	## -------------------------------------------------------------------------------------------------------------
	## Internal function that enables context menus
	##|
	setupContextMenu: (@contextMenuCallbackFunction) =>

		if @contextMenuCallSetup == 1 then return true
		@contextMenuCallSetup = 1

		@elTableHolder.bind "contextmenu", (e) =>

			data   = WidgetTag.getDataFromEvent(e)
			console.log "Context Menu:", data

			if !data.path? then return false

			if m = data.path.match(/^.group.([0-9]+)/)
				@onContextMenuGroup(parseInt(m[1]), data.coords)
				return false

			if m = data.path.match(/^.*Header[^a-zA-Z](.*)/)
				@onContextMenuHeader(m[1], data.coords)
				return false

			console.log "Context menu for #{data.path}"
			@onContextMenuData(e)
			return false

		true


	##|
	##|  Add a new sort rule in a given order
	##|  sortMode = 0 / toggle
	##|  sortMode = -1 / descending
	##|  sortMode = 1 / ascending
	##|  sortMode = other value / error
	##|

	addSortRule: (sourceName, sortMode)=>

		# console.log "adding sort rule table=#{@primaryTableName}, source=#{sourceName}, mode=#{sortMode}"

		found = null
		for rule in @sortRules
			if rule.source == sourceName
				found = rule
				break

		if found == null
			found = { source: sourceName, tableName: @primaryTableName, state: 0 }
			@sortRules = [ found ]

		if sortMode? and sortMode == 0
			found.state = found.state * -1
			if found.state == 0 then found.state = 1
		else if sortMode? and sortMode == 1
			found.state = 1
		else if sortMode? and sortMode == -1
			found.state = -1
		else
			@addSortRule sourceName, 0
		
		@updateRowData()
		return

	##|
	##|  Lock a given value at the top, does not matter what the sort is
	addLock: (id)=>
		@lockList[id] = true
		return true

	## -------------------------------------------------------------------------------------------------------------
	## internal function to apply sorting on table with column and sorting type
	##
	## @param [Object] column column on which sorting should be applied
	## @param [String] type it can be ASC|DESC
	##
	applySorting: (rowData) =>

		if !@sortRules?
			@sortRules = []

		@numLockedRows = Object.keys(@lockList).length
		if @sortRules.length == 0 and @numLockedRows == 0 then return rowData

		# console.log "applySorting", @sortRules, rowData

		sorted = rowData.sort (a, b)=>

			for rule in @sortRules
				if rule.state == 0 then continue

				# console.log "Get ", @primaryTableName, "key=", a.id,  b.id, "source=", rule.source
				aValue = DataMap.getDataField @primaryTableName, a.id, rule.source
				bValue = DataMap.getDataField @primaryTableName, b.id, rule.source

				if aValue? and !bValue then return rule.state
				if bValue? and !aValue then return rule.state * -1
				if !aValue? and !bValue? then return 0

				# console.log "Sort a=", aValue, "b=", bValue, rule.state

				if rule.state == -1 and aValue < bValue then return 1
				if rule.state == -1 and aValue > bValue then return -1

				if rule.state == 1 and aValue < bValue then return -1
				if rule.state == 1 and aValue > bValue then return 1

			return 0

		if @numLockedRows > 0
			finalList = []
			for rec in sorted
				if @lockList[rec.id]?
					finalList.push rec
					rec.locked = true

			for rec in sorted
				if !@lockList[rec.id]? then finalList.push rec
			return finalList


		# console.log "applySorting return:", sorted
		return sorted


	## -------------------------------------------------------------------------------------------------------------
	## Apply filters stored in "currentFilters" to each column and show/hide the rows
	##
	applyFilters: () =>

		##|
		##|  Generate a function that takes a row and returns true or false
		##|  to keep or filter the row.
		##|

		strJavascript = ""

		if @overallReduceFunction? and typeof @overallReduceFunction == "string"
			strJavascript += "try {\n" + @overallReduceFunction + ";\n} catch (e) { console.log(\"eee=\",e); }\n";

		filters = []
		for tableName, fieldList of @currentFilters
			for fieldName, filterValue of fieldList

				field = "row['#{fieldName}']"
				strJavascript += "if (typeof(#{field}) == 'undefined') return false;\n"
				strJavascript += "if (#{field} == null) return false;\n"
				strJavascript += "re = new RegExp('#{filterValue}', 'i');\n"
				strJavascript += "if (!re.test(#{field})) return false;\n";

		strJavascript += "return true;\n";
		# console.log "applyFilters Javascript:", strJavascript
		@reduceFunction = new Function("row", strJavascript)
		return true

	##|
	##|  If this table is not a "fixed size" table then we have to adjust the
	##|  widget height to allow all rows to show.
	##|
	updateFullHeight: ()=>
		if @fixedHeader then return

		h = 0
		if @showHeaders then h = h + @headerCellHeight
		if @showFilters then h = h + @filterCellHeight
		h = h + (@totalAvailableRows * @dataCellHeight)
		if not @fixedHeight
			@elTableHolder.height(h)

		return h

	##|
	##|  Refresh the list of available columns
	updateColumnList: ()=>

		@colList  = []
		@colByNum = {}

		##|
		##|  Add a checkbox column if needed
		if @showCheckboxes
			c = new TableViewColCheckbox(@primaryTableName)
			@colList.push c

		##|
		##|  Find the columns for the specific table name
		columns = DataMap.getColumnsFromTable(@primaryTableName, @columnReduceFunction)
		columns = columns.sort (a, b)->
			return a.getOrder() - b.getOrder()

		for col in columns
			if not col.getVisible() then continue

			foundInActionCol = false
			for acol in @actionColList
				if acol.getSource() == col.getSource()
					foundInActionCol = true
					break

			if foundInActionCol then continue

			if @isColumnEmpty(col)
				# console.log "Column is empty:", col.getSource()
				continue

			# if found == 0
			# console.log "LIST #{col.getSource()} to order: #{col.getOrder()}"
			@colList.push(col)

		##|
		##|  reset available columns and sort them
		total = 0
		sortedColList = @colList.sort (a, b)->
			return a.getOrder() - b.getOrder()

		for col in sortedColList

			foundInGroup = false
			for source in @currentGroups
				if source == col.getSource()
					col.isGrouped = true
					foundInGroup = true
					break

			if foundInGroup then continue

			# console.log "colByNum[#{total}] = ", col.getName()
			@colByNum[total] = col
			total++

		## added by xgao
		## to show sorting arrow on ActionColumn header
		for acol in @actionColList
			if acol.constructor.name is "TableViewCol"
				for sortrule in @sortRules
					if sortrule.tableName is @primaryTableName and sortrule.source is acol.getSource()
						acol.sort = sortrule.state
				@colByNum[total] = acol
				total++

		return true

	## -------------------------------------------------------------------------------------------------------------
	## function to update row data on the screen if new data has been added in datamapper they can be considered
	##
	updateRowData: () =>

		if !@isVisible() then return


		@applyFilters()
		@rowDataRaw = []
		allData     = DataMap.getValuesFromTable @primaryTableName, @reduceFunction

		##|
		##|  Path 1 - There are no groups defined so just quickly sort and filter
		##|
		if @currentGroups.length == 0
			@showGroupPadding = false
			##|
			##|  Simple data, no grouping
			filteredData = @applySorting(allData)
			for obj in filteredData
				@rowDataRaw.push { id: obj.id, group: null }

			@totalAvailableRows = @rowDataRaw.length
			@updateColumnList()

			@updateFullHeight()

			if @renderRequired then @real_render()
			@updateScrollbarSettings()
			@resetCachedFromSize()

			globalTableEvents.emitEvent "row_count", [ @primaryTableName, @totalAvailableRows ]
			return

		##|
		##|  Apply grouping filters
		groupedData        = {}
		@rowDataRaw        = []
		@showGroupPadding  = true
		currentGroupNumber = 0

		for item in allData

			key = ""
			for name in @currentGroups

				if key != "" then key += ", "

				displayName = name
				for col in @colList
					if col.getSource() == name then displayName = col.getName()

				value = DataMap.getDataField @primaryTableName, item.id, name
				key += displayName + ": " + value

			if !groupedData[key]?
				groupedData[key] = []

			groupedData[key].push item


		for value in Object.keys(groupedData).sort()
			currentGroupNumber++
			if currentGroupNumber > 7 then currentGroupNumber = 1

			filteredData = groupedData[value]
			if filteredData.length > 0
				##|
				##|  There are rows of data in this group so add the group to the row list.
				@rowDataRaw.push
					id     : null
					type   : "group"
					name   : value
					group  : currentGroupNumber
					count  : filteredData.length

				filteredData = @applySorting(filteredData)
				for obj in filteredData
					@rowDataRaw.push { id: obj.id, group: currentGroupNumber, visible: true}

				# for id in @applySorting()
					# @rowDataRaw.push { id: id, visible: true, group: currentGroupNumber }

		@totalAvailableRows = @rowDataRaw.length
		@updateColumnList()
		
		@updateFullHeight()

		if @renderRequired then @real_render()
		##
		@layoutShadow()
		@updateScrollbarSettings()
		##

		#@resetCachedFromSize()
		globalTableEvents.emitEvent "row_count", [ @primaryTableName, @totalAvailableRows ]

		return true

	##| -------------------------------------------------------------------------------------------------------------
	##| Enable a status bar along the bottom.
	setStatusBarEnabled: (isEnabled = true)=>
		@showStatusBar = isEnabled

	isVisible: ()=>
		if !@elTableHolder? then return false
		pos = @elTableHolder.position()
		if !pos? then return false
		tableWidth = @elTableHolder.outerWidth()

		if pos.top == 0 and pos.left == 0 and tableWidth == 0
			return false

		return true

	## -------------------------------------------------------------------------------------------------------------
	## set the holder element to go to the bottom of the screen
	##
	setHolderToBottom: () =>

		if @renderRequired then @real_render();
		@isFixedBottom = true
		@updateFixedPosition()

	##|
	##|  Move to the bottom location fully
	updateFixedPosition: (attemptCounter = 0)=>

		if !@isFixedBottom? or @isFixedBottom != true
			return

		height = $(window).height()

		pos = @elTableHolder.position()
		offset = @elTableHolder.offset()

		tableWidth = @elTableHolder.outerWidth()
		tableHeight = @elTableHolder.outerHeight()

		if !pos? or !offset? or pos.top == 0 and pos.left == 0 and tableWidth == 0
			if attemptCounter? and attemptCounter == 3 then return
			setTimeout ()=>
				if !attemptCounter? then attemptCounter = 0
				@updateFixedPosition(attemptCounter+1)
			, 10
			return

		# console.log "setHolderToBottom #{@primaryTableName} winHeight=#{height}, pos=", pos, " offset=", offset, "table=#{tableWidth} x #{tableHeight} v=", @elTableHolder[0].style.visibility

		newHeight = height - pos.top
		newHeight = Math.floor(newHeight)
		## if newHeight is too short, table content might not be shown
		if newHeight < minHeightOfTable then newHeight = minHeightOfTable
		@elTableHolder.height(newHeight)

		##|
		##|  If the width of the table scrolls, this fixes it
		newWidth = @elTableHolder.outerWidth()

		@resetCachedFromSize()
		#@updateVisibleText()

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

	getTotalActionWidth: ()=>
		##|
		##|  Width of all fixed right action columns
		total = 0
		for col in @actionColList
			total += col.getWidth()

		return total

	##|
	##|  Total available rows to display excluding headers
	getTableTotalRows: ()=>
		return @totalAvailableRows

	getTableTotalCols: ()=>
		#return Object.keys(@colByNum).length

		total = 0
		for col in @colList
		#for index, col of @colByNum
			if col.isGrouped? and col.isGrouped == true then continue
			total++

		# console.log "total cols=", total, "[", @colList, "]"
		return total

	getTableVisibleWidth: ()=>
		if @cachedVisibleWidth? && @cachedVisibleWidth > 0 then return @cachedVisibleWidth
		maxWidth = @elTableHolder.width()
		if @virtualScrollV? and @virtualScrollV.visible then maxWidth -= 20
		@cachedVisibleWidth = maxWidth - @getTotalActionWidth()

	getTableVisibleHeight: ()=>
		if @cachedVisibleHeight? && @cachedVisibleHeight > 0 then return @cachedVisibleHeight
		maxHeight  = @elTableHolder.height()
		if @virtualScrollH? and @virtualScrollH.visible then maxHeight -= 20
		@cachedVisibleHeight = maxHeight

	##|
	##|  Returns the maximum rows visible starting at the end of the rows
	getTableMaxVisibleRows: ()=>
		if @cachedMaxTotalVisibleRows? then return @cachedMaxTotalVisibleRows

		y           = 0
		visRowCount = 0
		maxHeight   = @getTableVisibleHeight()
		rowNum      = @getTableTotalRows() - 1

		while y < maxHeight

			if rowNum < 0 then break
			y = y + @getRowHeight({rowNum:rowNum, visibleRow:visRowCount})
			rowNum--
			visRowCount++

		if visRowCount > 0 then @cachedMaxTotalVisibleRows = visRowCount
		return visRowCount

	##|
	##|  Number of visible rows
	getTableVisibleRows: ()=>
		if @cachedTotalVisibleRows? then return @cachedTotalVisibleRows

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

		if visRowCount > 0 then @cachedTotalVisibleRows = visRowCount
		return visRowCount

	getTableMaxVisibleCols: ()=>

		if @cachedMaxTotalVisibleCol? then return @cachedMaxTotalVisibleCol

		visColCount = 0
		x           = 0
		colNum      = @getTableTotalCols() - 1
		maxWidth    = @getTableVisibleWidth()

		while x < maxWidth and colNum >= 0

			col = @colByNum[colNum]
			location =
				colNum     : colNum
				tableName  : col.tableName
				sourceName : col.getSource()
				visibleCol : colNum

			if (colNum > 0) and @shouldSkipCol(location)
				colNum--
				continue

			col.currentWidth = @getColWidth(location)
			x = x + col.currentWidth
			visColCount++
			colNum--

		if visColCount > 0 then @cachedMaxTotalVisibleCol = visColCount
		return visColCount


	##|
	##|  Number of visible columns
	getTableVisibleCols: ()=>

		if @cachedTotalVisibleCols? then return @cachedTotalVisibleCols

		visColCount = 0
		x           = 0
		colNum      = @offsetShowingLeft
		maxWidth    = @getTableVisibleWidth()
		totalCols   = @getTableTotalCols()

		while x < maxWidth and colNum < totalCols

			col = @colByNum[colNum]
			location =
				colNum     : colNum
				tableName  : col.tableName
				sourceName : col.getSource()
				visibleCol : colNum

			if (colNum < totalCols) and @shouldSkipCol(location)
				console.log "shouldSkip ", location.colNum
				colNum++
				continue

			if colNum >= totalCols
				break

			col.currentWidth = @getColWidth(location)
			x = x + col.currentWidth
			visColCount++
			colNum++

		if visColCount > 0 then @cachedTotalVisibleCols = visColCount
		return visColCount

	##|
	##|  Compute the width of a given column
	getColWidth: (location)=>

		if location.cellType == "group"
			maxWidth = @getTableVisibleWidth()
			if location.visibleCol == 1 then return 200
			if location.visibleCol == 2 then return 90
			if location.visibleCol == 3 then return maxWidth-290
			return 0

		if !@colByNum[location.colNum]?
			# console.log "getColWidth Invalid col:", location.colNum, @colByNum
			return 10

		if @colByNum[location.colNum].actualWidth? and !isNaN(@colByNum[location.colNum].actualWidth)
			# console.log "getColWidth actual ", @colByNum[location.colNum].getName(), "=",Math.floor(@colByNum[location.colNum].actualWidth)
			return Math.floor(@colByNum[location.colNum].actualWidth)

		# if !@colByNum[location.colNum].actualWidth?
			# return @colByNum[location.colNum].getWidth()
		# console.log "getColWidth colNum=#{location.colNum} source=[#{location.sourceName}] set=", @colByNum[location.colNum].getWidth(), " width:", @colByNum[location.colNum].actualWidth
		# console.log "getColWdith return ", @colByNum[location.colNum].getWidth()

		return @colByNum[location.colNum].getWidth()

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
		if @colByNum[location.colNum]?
			# console.log "Checking clickable:", location.colNum, " =",@colByNum[location.colNum].getClickable()
			return @colByNum[location.colNum].getClickable()
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
		if location.cellType != "data" then return @primaryTableName
		return @colByNum[location.colNum].tableName

	getCellCalculation: (location)->
		if location.cellType == "invalid" then return null
		if !@colByNum[location.colNum]? then return null
		return @colByNum[location.colNum].getIsCalculation()

	getCellSource: (location)=>
		if location.cellType == "invalid" then return null
		if !@colByNum[location.colNum]? then return null
		# console.log "getCell #{location.colNum}", @colByNum[location.colNum].getSource()
		return @colByNum[location.colNum].getSource()

	getCellRecordID: (location)=>
		if !@rowDataRaw[location.rowNum]? then return 0
		return @rowDataRaw[location.rowNum].id

	getCellFormatterName: (location)=>
		return @colByNum[location.colNum].getFormatterName()

	shouldAdvanceCol: (location)=>
		return true

	getCellDataPath: (location)=>
		if location.cellType == "data"
			return "/#{location.tableName}/#{location.recordId}/#{location.sourceName}"

		if location.cellType == "group"
			return "/group/#{location.rowNum}"

		return "/unknown/" + location.celltype

	setHeaderFilterField: (location)=>

		if location.cell.children.length == 0
			location.cell.addClass "dataFilterWrapper"
			location.cell.add "input", "dataFilter"
			location.cell.children[0].bind "keyup", @onFilterKeypress

		location.cell.children[0].setDataPath "/#{location.tableName}/Filter/#{location.sourceName}"
		true

	setHeaderField: (location)=>

		# console.log "Header children=", location.cell.children.length, "current=", location.cell.currentCol, " vs", location.colNum
		# if location.cell.currentCol == location.colNum
			# return

		# console.log "Force Redraw Header:", location

		location.cell.currentCol = location.colNum
		location.cell.html ""
		location.cell.removeClass "spacer"

		if location.visibleRow == 0

			@colByNum[location.colNum].sort = 0
			for sort in @sortRules
				if sort.source == @colByNum[location.colNum].getSource()
					@colByNum[location.colNum].sort = sort.state

			@colByNum[location.colNum].RenderHeader location.cell, location
			location.cell.setDataPath "/#{location.tableName}/Header/#{location.sourceName}"

		else

			@setHeaderFilterField(location)


		true

	setHeaderGroupField: (location)=>
		##|
		##|  Setup the div that is in a header row along left where the group indicator color
		##|  normally goes.  Headers don't have groups
		if location.visibleRow == 0
			location.cell.addClass "tableHeaderField"
		else if location.visibleRow == 1
			location.cell.addClass "dataFilterWrapper"

		true

	setDataField: (location)=>

		if location.cellType == "invalid"
			location.cell.hide()
			return

		if location.cellType == "group"
			if location.visibleCol == 1
				location.cell.html @rowDataRaw[location.rowNum].name
			else if location.visibleCol == 3
				location.cell.html ""
			else if location.visibleCol == 2
				if @rowDataRaw[location.rowNum].count == 1
					location.cell.html "#{@rowDataRaw[location.rowNum].count} Record"
				else
					location.cell.html "#{@rowDataRaw[location.rowNum].count} Records"
			return

		col = @colByNum[location.colNum]
		if col.getSource() == "row_selected"

			if @getRowLocked(@rowDataRaw[location.rowNum].id)
				location.cell.html "<i class='fa fa-lock'></i>"
			else if @getRowSelected(@rowDataRaw[location.rowNum].id)
				location.cell.html @imgChecked
			else
				location.cell.html @imgNotChecked

		else
			displayValue = DataMap.getDataFieldFormatted col.tableName, location.recordId, location.sourceName
			location.cell.html displayValue

		if @lockList? and @lockList.length > 0


			aValue = DataMap.getDataField col.tableName, location.recordId, location.sourceName
			if typeof aValue == "number"
				bValue = DataMap.getDataField col.tableName, @lockList[0], location.sourceName
				if aValue > bValue
					location.cell.addClass "valueHigher"
					location.cell.removeClass "valueLower"
				else if aValue < bValue
					location.cell.addClass "valueLower"
					location.cell.removeClass "valueHigher"
				else
					location.cell.removeClass "valueLower"
					location.cell.removeClass "valueHigher"
			else
				location.cell.removeClass "valueLower"
				location.cell.removeClass "valueHigher"

		true

	shouldSkipCol: (location)=>
		if !@colByNum[location.colNum]? then return true
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

	isResizable: (location)=>
		if not @showResize then return false
		if location.visibleRow > 0 then return false
		if not location.isHeader then return false
		if @showGroupPadding and location.visibleCol == 0 then return false
		if location.sourceName == "row_selected" then return false
		if location.colNum >= location.totalColCount then return false
		return true

	##|
	##|  Setup the spacer cell for a location
	initializeSpacerCell: (location, spacer)=>

		if location.groupNum?
			spacer.setClassOne "groupRowChart#{location.groupNum}", /^groupRowChart/
		else
			spacer.setClassOne null, /^groupRowChart/

		spacer.setDataPath "grab"
		spacer.setDataValue "rn", location.rowNum
		spacer.setDataValue "cn", location.colNum
		spacer.setDataValue "vr", 0
		spacer.setDataValue "vc", 0
		true

	updateCellClasses: (location, div)=>

		div.show()

		##|
		##|  Set the column / row data on the element
		div.setDataValue "rn", location.rowNum
		div.setDataValue "cn", location.colNum
		div.setDataValue "vr", location.visibleRow
		div.setDataValue "vc", location.visibleCol

		if location.groupNum?
			div.setClassOne "groupRowChart#{location.groupNum}", /^groupRowChart/
		else
			div.setClassOne null, /^groupRowChart/

		##|
		##|  Align right/center as left is the default
		location.cell.setClass "even", @getCellStriped(location)
		location.cell.setClass "first-action", false

		##|
		##|  Apply alignment to the cell
		location.align = @getCellAlign(location)
		location.cell.setClass "text-right", (location.align == "right")
		location.cell.setClass "text-center", (location.align == "center")

		##|
		##|  Fixed calculation
		location.cell.setClass "calculation", @getCellCalculation(location)

		true

	incrementColumn: (location, showSpacer)=>

		if location.x + location.colWidth > location.maxWidth
			location.colWidth = location.maxWidth - location.x

		# if (location.cellType == "data" or location.cellType == "locked") and location.colNum + 1 == location.totalColCount
		# 	location.colWidth = location.maxWidth - location.x

		if location.spacer?

			location.cell.move location.x, 0, location.colWidth-3, location.rowHeight
			location.spacer.move location.colWidth+location.x-3, 0, 3, location.rowHeight
			location.spacer.show()
			location.spacer.addClass "spacer"
			location.spacer.html ""
			location.shadowVisibleCol++

		else

			location.cell.move location.x, 0, location.colWidth, location.rowHeight

		location.x += location.colWidth
		location.shadowVisibleCol++
		location.visibleCol++

		true

	updateVisibleActionRowText: (location, acol, cell)=>

		location.tableName = acol.tableName
		location.sourceName = acol.getSource()

		cell.setClass "clickable", acol.getClickable()
		if acol.render?
			try
				# console.log "[#{location.tableName}][#{location.recordId}][#{location.sourceName}]"
				currentValue = DataMap.getDataField location.tableName, location.recordId, location.sourceName
				displayValue = acol.render(currentValue, location.tableName, location.sourceName, location.recordId)
			catch e
				console.log "updateVisibleActionRow locaiton=", location
				console.log "Custom render error:", e
				displayValue = ""

			cell.html displayValue
		else
			displayValue = DataMap.getDataFieldFormatted acol.tableName, location.recordId, acol.getSource()
			cell.html displayValue

		true

	updateVisibleActionRow: (location)=>

		count = 0
		for acol in @actionColList

			if @shadowCells[location.visibleRow].children.length <= location.shadowVisibleCol
				@shadowCells[location.visibleRow].addDiv "cell"
				@shadowCells[location.visibleRow].children[location.shadowVisibleCol].setAbsolute()

			cell = @shadowCells[location.visibleRow].children[location.shadowVisibleCol]
			cell.show()

			cell.move location.x, 0, acol.getWidth(), location.rowHeight

			cell.setClass "text-right", acol.getAlign() == "right"
			cell.setClass "text-center", acol.getAlign() == "center"
			cell.setClass "first-action", count++ == 0

			cell.removeClass "spacer"
			cell.setClass "even", @getCellStriped(location)

			cell.setDataValue "rn", location.rowNum
			cell.setDataValue "cn", location.colNum
			cell.setDataValue "vr", location.visibleRow
			cell.setDataValue "vc", location.visibleCol
			cell.setDataValue "action", acol.getSource()
			if location.isHeader
				cell.setDataPath "/#{@primaryTableName}/Header/#{acol.getSource()}"	
			else
				cell.setDataPath "/#{@primaryTableName}/#{location.recordId}/#{acol.getSource()}"

			if location.groupNum?
				cell.setClassOne "groupRowChart#{location.groupNum}", /^groupRowChart/
			else
				cell.setClassOne null, /^groupRowChart/

			if location.isHeader

				if location.visibleRow == 0
					acol.RenderHeader cell, location
					cell.show()
				else
					location.cell = cell
					location.sourceName = acol.getSource()
					@setHeaderFilterField location
			else

				if location.state == "group"
					cell.removeClass "clickable"
					cell.html ""
				else
					@updateVisibleActionRowText(location, acol, cell)

			location.x += acol.getWidth()
			location.shadowVisibleCol++

	##|
	##|  Draw a single row, returns the next rowNum.
	##|
	updateVisibleTextRow: (location)=>

		location.x                = 0    ## Pixel location of current column
		location.visibleCol       = 0
		location.colNum           = @offsetShowingLeft
		location.shadowVisibleCol = 0

		while location.x < location.maxWidth

			if location.colNum >= location.totalColCount then break

			if @shadowCells[location.visibleRow].children.length <= location.shadowVisibleCol
				@shadowCells[location.visibleRow].addDiv "cell"
				@shadowCells[location.visibleRow].children[location.shadowVisibleCol].setAbsolute()

			location.cell       = @shadowCells[location.visibleRow].children[location.shadowVisibleCol]
			location.spacer     = null
			location.isHeader   = @isHeaderCell(location)
			location.groupNum   = @getCellGroupNumber(location)
			location.cellType   = @getCellType(location)
			location.tableName  = @getCellTablename location
			location.sourceName = @getCellSource location
			location.colWidth   = @getColWidth(location)

			if location.cellType == "invalid"
				console.log "Invalid cell at colNum=#{location.colNum}"
				break

			if @shouldSkipCol(location)
				location.colNum++
				continue

			if @isResizable(location)
				##|
				##|  Headers get an extra spacer column
				if @shadowCells[location.visibleRow].children.length <= location.shadowVisibleCol+1
					@shadowCells[location.visibleRow].addDiv "spacer"
					@shadowCells[location.visibleRow].children[location.shadowVisibleCol+1].setAbsolute()

				@initializeSpacerCell(location, @shadowCells[location.visibleRow].children[location.shadowVisibleCol+1])
				location.spacer = @shadowCells[location.visibleRow].children[location.shadowVisibleCol+1]

			if @showGroupPadding and location.visibleCol == 0
				##|
				##|  This is a group indicator column
				location.colWidth = @groupPaddingWidth

				if !location.isHeader
					location.cell.setClassOne "groupRowChart#{location.groupNum}", /^groupRowChart/
					location.cell.removeClass "even"
					location.cell.html ""
				else
					@setHeaderGroupField location

				@incrementColumn(location)
				continue

			@updateCellClasses(location, location.cell)

			if location.isHeader

				@setHeaderField(location)

			else

				location.recordId = @getCellRecordID(location)

				location.cell.setClass "clickable",   @getCellClickable(location)
				location.cell.setClass "editable",    @getCellEditable(location)
				location.cell.setClass "row_checked", @getRowSelected(location.recordId)
				location.cell.setClass "row_locked",  @getRowLocked(location.recordId)

				location.cell.setDataPath @getCellDataPath(location)
				@setDataField(location)

			@incrementColumn(location)
			if @shouldAdvanceCol(location)
				location.colNum++

		##|
		##|  Add in the action rows
		@updateVisibleActionRow(location)

		##|
		##|  Hide any remaining cached cells on the right
		while @shadowCells[location.visibleRow].children[location.shadowVisibleCol]?
			@shadowCells[location.visibleRow].children[location.shadowVisibleCol].resetDataValues()
			@shadowCells[location.visibleRow].children[location.shadowVisibleCol].hide()
			@shadowCells[location.visibleRow].children[location.shadowVisibleCol].setDataPath(null);
			location.shadowVisibleCol++

		true

	updateVisibleText: ()=>

		# console.log "updateVisibleText showingLeft=", @offsetShowingLeft
		if !@elTheTable? then return

		if !@offsetShowingTop? or @offsetShowingTop < 0
			@offsetShowingTop = 0

		if !@offsetShowingLeft? or @offsetShowingLeft < 0
			@offsetShowingLeft = 0

		if @rowDataRaw.length == 0
			#return

			if !@noDataCell?
				@noDataCell = @elTheTable.addDiv "tableRow"
				@noDataCell.setAbsolute()
				@noDataCell.setZ(1)
			else if @noDataCell.visible
				return

			marginRight = if @virtualScrollV.visible then @virtualScrollV.displaySize else 0
			marginTop = @headerCellHeight + @getRowHeight()
			@noDataCell.move(0, @headerCellHeight + @getRowHeight(), @elTableHolder.width() - marginRight, @elTableHolder.height() - marginTop)
			@noDataCell.html "No data available."
			@noDataCell.show()

			r1 = @virtualScrollV.setRange 0, 0, 0, 0
			r2 = @virtualScrollH.setRange 0, 0, 0, 0
			return

		if @noDataCell?
			@noDataCell.hide()

		y               = 0
		groupState      = null
		maxHeight       = @getTableVisibleHeight()
		totalRowCount   = @getTableTotalRows()
		refreshRequired = false

		##|
		##|  For rabbit mouse scrolling, this resets the offset back to a reasonable amount
		##|  so that the refreshNeeded doesn't have to loop through a bunch of times
		##|
		if @offsetShowingTop >= totalRowCount
			@offsetShowingTop = totalRowCount - 1

		location =
			visibleRow    : 0
			rowNum        : 0
			totalColCount : @getTableTotalCols()
			maxWidth      : @getTableVisibleWidth()
			actionWidth   : @getTotalActionWidth()

		lockRowsRemain = @numLockedRows
		hasFinishedLockedRows = false
		# @offsetShowingTop

		# console.log "updateVisibleText offsetShowingTop=", @offsetShowingTop, " offsetShowingLeft=", @offsetShowingLeft, " maxRow=", totalRowCount, "maxCol=", totalColCount
		while y < maxHeight

			if lockRowsRemain ==0 and !hasFinishedLockedRows
				hasFinishedLockedRows = true
				location.rowNum += @offsetShowingTop

			location.rowHeight = @getRowHeight(location)
			location.state     = @getRowType(location)

			if !@shadowCells[location.visibleRow]?
				@shadowCells[location.visibleRow] = @elTheTable.addDiv "tableRow"
				@shadowCells[location.visibleRow].setAbsolute()
				@shadowCells[location.visibleRow].show()

			##|
			##|  Row div goes the entire width
			@shadowCells[location.visibleRow].move 0, y, location.maxWidth+location.actionWidth, location.rowHeight

			if location.state == "invalid"
				##|
				##|  Scroll down too far
				if @offsetShowingTop > 0
					@offsetShowingTop--
					refreshRequired = true

				break

			else if location.state == "skip"
				location.rowNum++
				continue

			else if location.state == "group"
				@shadowCells[location.visibleRow].show()
				@shadowCells[location.visibleRow].removeClass "tableRow"
				@updateVisibleTextRow location
				location.rowNum++

			else if location.state == "locked"
				@shadowCells[location.visibleRow].show()
				@shadowCells[location.visibleRow].removeClass "tableRow"
				@updateVisibleTextRow location

			else if location.state == "data"
				@shadowCells[location.visibleRow].show()
				@shadowCells[location.visibleRow].addClass "tableRow"
				@updateVisibleTextRow location
				location.rowNum++
				if lockRowsRemain > 0 then lockRowsRemain--

			else
				# console.log "Unknown state at v=#{visibleRow}, r=#{rowNum}:", location.state
				location.rowNum++

			y += location.rowHeight
			location.visibleRow++

		if refreshRequired
			#@resetCachedFromSize()
			return true

		while @shadowCells[location.visibleRow]?
			@shadowCells[location.visibleRow].hide()
			@shadowCells[location.visibleRow].resetDataValues()
			location.visibleRow++

		#@updateScrollbarSettings()
		true

	resetCachedFromScroll: ()=>
		@cachedTotalVisibleCols    = null
		@cachedTotalVisibleRows    = null
		@cachedMaxTotalVisibleCol  = null
		@cachedMaxTotalVisibleRows = null
		#@updateVisibleText()
		@onMouseOut()
		true

	resetCachedFromSize: ()=>
		@cachedTotalVisibleCols  = null
		@cachedTotalVisibleRows  = null
		@cachedVisibleWidth      = null
		@cachedVisibleHeight     = null
		@cachedLayoutShadowWidth = null

		for col in @colList
			col.currentCol = null

		@layoutShadow()
		#@updateVisibleText()
		@onMouseOut()
		true

	##|
	##|  Up the visibility and settings of the scrollbars
	updateScrollbarSettings: ()=>

		currentVisibleCols = @getTableMaxVisibleCols()
		currentVisibleRows = @getTableMaxVisibleRows()

		maxAvailableRows = @getTableTotalRows()
		maxAvailableCols = @getTableTotalCols()
		
		##|
		##|  Don't show more rows than fit on the screen
		if @offsetShowingTop >= maxAvailableRows - currentVisibleRows
			# console.log "#{@primaryTableName} updateScrollbarSettings offsetShowingTop #{@offsetShowingTop} >= #{maxAvailableRows} - #{currentVisibleRows}"
			@offsetShowingTop = maxAvailableRows - currentVisibleRows

		if @offsetShowingLeft >= maxAvailableCols - currentVisibleCols
			# console.log "#{@primaryTableName} updateScrollbarSettings offsetShowingLeft #{@offsetShowingLeft} >= #{maxAvailableCols} - #{currentVisibleCols}"
			@offsetShowingLeft = maxAvailableCols - currentVisibleCols
			# console.log "#{@primaryTableName} updateScrollbarSettings, reset offsetShowingLeft to ", @offsetShowingLeft

		##|
		##| Don't set offset as less than 0
		if @offsetShowingTop < 0 then @offsetShowingTop = 0

		if @offsetShowingLeft < 0 then @offsetShowingLeft = 0

		if @elStatusScrollTextRows?
			@elStatusScrollTextRows.html "Rows #{@offsetShowingTop+1} - #{@offsetShowingTop+currentVisibleRows} of #{maxAvailableRows}"
			@elStatusScrollTextCols.html "Cols #{@offsetShowingLeft+1}-#{@offsetShowingLeft+currentVisibleCols} of #{maxAvailableCols}"

		# console.log "#{@primaryTableName} updateScrollbarSettings H:(#{currentVisibleCols} vs #{maxAvailableCols}) V:(#{currentVisibleRows} vs #{maxAvailableRows})"

		##|
		##|  Scrollbar settings show/hide
		r1 = @virtualScrollV.setRange 0, maxAvailableRows, currentVisibleRows, @offsetShowingTop
		r2 = @virtualScrollH.setRange 0, maxAvailableCols, currentVisibleCols, @offsetShowingLeft
		if r1 or r2
			@resetCachedFromSize()
		@updateVisibleText()

	##|
	##|  Return true if a column is empty
	##|
	isColumnEmpty: (col)=>

		if @rowDataRaw.length == 0 then return false
		if col.getEditable() == true then return false
		if col.getIsCalculation() == true then return false

		if !@cachedColumnEmpty? then @cachedColumnEmpty = {}
		if @cachedColumnEmpty[col.getSource()]? then return @cachedColumnEmpty[col.getSource()]
		@cachedColumnEmpty[col.getSource()] = false

		source = col.getSource()
		for obj in @rowDataRaw
			if !obj.id? then continue
			value = DataMap.getDataField col.tableName, obj.id, source
			if !value? then continue

			if typeof value == "string" and value.length > 0 then return false
			if typeof value == "number" and value != 0 then return false
			if typeof value == "boolean" then return false
			if typeof value == "object" then return false

		@cachedColumnEmpty[col.getSource()] = true
		return true

	##|
	##|  Find the best fit for the data in a given column
	##|
	findBestFit: (col)=>

		if !@cachedBestFit? then @cachedBestFit = {}
		if @cachedBestFit[col.getSource()] then return @cachedBestFit[col.getSource()]

		max    = 10
		source = col.getSource()
		for obj in @rowDataRaw
			if !obj.id? then continue
			value = DataMap.getDataFieldFormatted col.tableName, obj.id, source
			if !value? then continue
			len   = value.toString().length
			if len > max then max = len

		if max < 10 then max = 10
		if max > 40 then max = 40
		@cachedBestFit[col.getSource()] = (max * 8)
		return (max * 8)

	setAutoFillWidth: ()=>
		@autoFitWidth = true
		delete @cachedLayoutShadowWidth
		true

	##|
	##|  For a standard table, adjust the width of the columns to fit the space available
	##|  and if it's not a close fit, then scroll the table instead
	##|
	layoutShadow: ()=>

		maxWidth   = @getTableVisibleWidth()
		if @cachedLayoutShadowWidth? and @cachedLayoutShadowWidth == maxWidth then return
		@cachedLayoutShadowWidth = maxWidth

		autoAdjustableColumns = []
		for i in @colList
			if i.getAutoSize()
				if !i.actualWidth?
					i.actualWidth = @findBestFit(i)
				autoAdjustableColumns.push(i)

		if !@autoFitWidth? or @autoFitWidth == false then return false

		totalWidth = 0

		colNum = 0
		for i in @colList

			if i.isGrouped then continue

			location =
				colNum     : colNum
				visibleCol : colNum
				tableName  : @primaryTableName
				sourceName : i.getSource()

			w = @getColWidth(location)
			totalWidth += w
			colNum++

		diffAmount = (maxWidth - totalWidth) / autoAdjustableColumns.length
		# console.log "diffAmount=#{diffAmount}", (maxWidth - totalWidth)

		diffAmount = Math.floor(diffAmount)

		for col in autoAdjustableColumns
			col.actualWidth += diffAmount

		# console.log "layoutShadow maxWidth=#{maxWidth} totalWidth=#{totalWidth}", autoAdjustableColumns
		# console.log "diffAmount=#{diffAmount}"
		true

	updateStatusText: (message...)=>
		if !@elStatusText? then return
		str = message.join ", "
		@elStatusText.html str
		return true

	## -------------------------------------------------------------------------------------------------------------
	## function to render the added table inside the table holder element
	##
	## @example tableview.render()
	## @return [Boolean]
	##

	render: () =>

		if !@widgetBase?
			@renderRequired = true

		return true

	real_render: () =>

		@renderRequired = false

		if !@shadowCells?
			@shadowCells = {}

		if !@fixedHeader
			@elTableHolder.width("100%")

		@elTableHolder.html("")

		@widgetBase    = new WidgetBase()
		tableWrapper   = @widgetBase.addDiv "table-wrapper", "tableWrapper#{@gid}"
		outerContainer = tableWrapper.addDiv "outer-container"
		@elTheTable    = outerContainer.addDiv "inner-container tableview"

		@virtualScrollV = new VirtualScrollArea outerContainer, true
		@virtualScrollH = new VirtualScrollArea outerContainer, false

		##|
		##|  Make room for the status bar
		if @showStatusBar? and @showStatusBar == true

			@virtualScrollH.bottomPadding = 26
			@virtualScrollH.resize()

			@virtualScrollV.bottomPadding = 26
			@virtualScrollV.resize()

			@elStatusBar = tableWrapper.addDiv "statusbar"

			@elStatusText = @elStatusBar.addDiv "scrollStatusText"
			@elStatusText.html "Ready."

			@elStatusScrollTextRows = @elStatusBar.addDiv "scrollTextRows"
			@elStatusScrollTextRows.html ""

			@elStatusScrollTextCols = @elStatusBar.addDiv "scrollTextCols"
			@elStatusScrollTextCols.html ""

			@elStatusActionCopy = @elStatusBar.addDiv "statusActionsCopy"
			@elStatusActionCopy.html "<i class='fa fa-copy'></i> Copy"
			@elStatusActionCopy.on "click", @onActionCopyCell

		##|
		##|  Get the data from that table
		if !@rowDataRaw? or @rowDataRaw.length == 0
			@updateRowData()

		@layoutShadow()
		@updateVisibleText()
		@elTableHolder.append tableWrapper.el
		@internalSetupMouseEvents()

		##|
		##|  This is a new render which means we need to re-establish any context menu
		@contextMenuCallSetup = 0

		##|
		##|  Setup context menu on the header
		@setupContextMenu @contextMenuCallbackFunction

		@tooltipWindow = new FloatingWindow(0, 0, 100, 100, @elTableHolder)

		true


	## -------------------------------------------------------------------------------------------------------------
	## function to sort the table base on column and type
	##
	## @param [String] name name of the column to apply sorting on
	## @param [String] type it can be ASC|DSC
	##
	sortByColumn: (name, type) =>
		if type is "ASC"
			sortType = 1
		else if type is "DSC"
			sortType = -1
		else
			sortType = 0
		for key, col of @colByNum
			if col.getSource() is name
				@addSortRule name, sortType
				return true
		false

	##|
	##|  Add a group by condition
	groupBy: (columnSource) =>

		for name in @currentGroups
			if name == columnSource then return

		@currentGroups.push columnSource
		@updateRowData()
		@updateVisibleText()
		return


	## -----------------------------------------------------------------------------------------------ƒmove--------------
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

		if @getColumnType(columnName) isnt 1
			console.log "Filter on ActionColumn : Not working"
			return false
		
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
			col = @findColumn(m[1])
			# console.log "Searching clickable: [#{m[1]}]", col
			if col?
				col.clickable = true
				@updateVisibleText()

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

		if @offsetShowingLeft + @getTableVisibleCols() + 1 < @getTableTotalCols()
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

		lastFocusRow = @currentFocusRow
		lastFocusCol = @currentFocusCol
		if !@currentFocusRow? then return

		if @offsetShowingTop > 0
			@scrollUp(-1)
			@setFocusCell(@currentFocusRow, @currentFocusCol)
			return

		if @currentFocusRow == 0
			return

		if not @setFocusCell(@currentFocusRow-1, @currentFocusCol)
			@setFocusCell(lastFocusRow, lastFocusCol)

		true

	moveCellDown: ()=>

		lastFocusRow = @currentFocusRow
		lastFocusCol = @currentFocusCol
		if !@currentFocusRow? then return

		visRow = @getTableVisibleRows()
		maxRow = @getTableTotalRows()
		if @offsetShowingTop + visRow + 1 < maxRow
			@scrollUp(1)
			@setFocusCell(@currentFocusRow, @currentFocusCol)
			return

		if @offsetShowingTop+1+@getTableVisibleRows >= @getTableVisibleRows()
			@scrollUp(1)
			@setFocusCell(@currentFocusRow, @currentFocusCol)
			return

		if not @setFocusCell(@currentFocusRow+1, @currentFocusCol)
			@setFocusCell(lastFocusRow, lastFocusCol)

		true

	##|
	##|  Auto select the first visible cell
	setFocusFirstCell: ()=>

		@setFocusCell(0,0)
		true

	##|
	##|  Copy to clipboard the current cell
	onActionCopyCell: ()=>

		if !@currentFocusCell? then return
		path = @currentFocusCell.getDataValue("path")
		if path?
			parts     = path.split("/")
			tableName = parts[1]
			record_id = parts[2]
			source    = parts[3]
			item      = @findRowFromPath(path)
			console.log "COPY:", item[source]

		true

	##|
	##|  Focus on a path cell
	setFocusCell: (visibleRow, visColNum, e) =>

		if !@allowSelectCell
			return false
		##|
		##|  Remove old focus
		if @currentFocusCell? and @currentFocusCell.removeClass?
			@currentFocusCell.removeClass "cellfocus"

		@currentFocusCell = null
		@currentFocusCol  = null
		@currentFocusRow  = null
		@currentFocusPath = null

		if visibleRow == null or visColNum == null
			@updateStatusText "Nothing selected"
			return false

		element = null
		for tag_id, tag_data of globalTagData
			if tag_data.vr == visibleRow and tag_data.vc == visColNum
				element = @elTableHolder.find("[data-id='#{tag_id}']")
				path    = tag_data.path
				rowNum  = tag_data.rn
				colNum  = tag_data.cn
				console.log "find data-id=#{tag_id}:", element[0]
				break

		if !element?
			console.log "Unable to find element for #{visibleRow}/#{visibleCol}"
			return false

		if path?
			@currentFocusCell = path
			parts = path.split("/")
			if parts?
				tableName = parts[1]
				record_id = parts[2]
				source    = parts[3]

		cellType = @getCellType { visibleRow: visibleRow, visibleCol: visColNum, rowNum: rowNum, colNum: colNum }

		if !source?
			source = @getCellSource { visibleRow: visibleRow, visibleCol: visColNum, rowNum: rowNum, colNum: colNum }

		console.log "setFocusCell #{visibleRow}, #{visColNum} = #{cellType} | #{source}"
		if !visibleRow? or !visColNum? or cellType != "data"
			@updateStatusText "Nothing selected"
			return false

		@currentFocusRow = parseInt visibleRow
		@currentFocusCol = parseInt visColNum

		if visibleRow == null or visColNum == null
			@currentFocusRow = null
			@currentFocusCol = null
			@updateStatusText "Nothing selected"
			return false

		@currentFocusCell = @shadowCells[visibleRow].children[visColNum]

		if @currentFocusCell?
			path = @currentFocusCell.getDataValue("path")
			if path?
				@currentFocusPath = path
				@currentFocusCell.addClass "cellfocus"
				item = @findRowFromPath(path)
				@emitEvent 'focus_cell', [ path, item ]

				@updateStatusText item[source]

		return true

	##|
	##|  Returns true if a path is visible
	findPathVisible: (path)=>

		for idx, shadow of @shadowCells
			for cell in shadow.children
				if cell.getDataValue("path") == path
					return cell

		return null

	show: ()=>
		return

	hide: ()=>
		return

	destroy: ()=>
		return


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
		for part, i in parts when i >= 4 
			colName = colName + '/' + part
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
			return "Header"

		data = {}
		colNum = 0
		data = DataMap.getDataForKey @primaryTableName, keyValue
		if !data? then return null
		data["id"] = keyValue

		return data

	## -------------------------------------------------------------------------------------------------------------
	## check if a column is data column or action column
	##
	## @param [String] colName name of column to be checked
	## @return [Integer] 1 : Data Column, 2 : Action Column, 0 : not both
	##
	getColumnType: (colName) =>

		for index, dataCol of @colByNum
			if dataCol.getSource() is colName
				return 1

		for actionCol in @actionColList
			if actionCol.getSource() is colName
				return 2

		return 0

	##
	## set column's isGrouped property as false
	##
	## @param [string] colName name of column
	## @return [Boolean] true if action is succeeded, else, false
	##
	ungroupColumn: (colName) =>

		columns = DataMap.getColumnsFromTable(@primaryTableName, @columnReduceFunction)
		for col in columns
			if col.getSource() is colName
				#DataMap.changeColumnAttribute @primaryTableName, colName, "isGrouped", false
				col.isGrouped = false
				#DataMap.changeColumnAttribute @primaryTableName, colName, "visible", true
				return true

		return false
