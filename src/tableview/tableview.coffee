# A Table manager class that is designed to quickly build scrollable tables
# @namespace TableView
# @example How to create table view
#		new TableView $('.tableHolder')
class TableView


	imgChecked     : "<img src='images/checkbox.png' width='16' height='16' alt='Selected' />"
	imgNotChecked  : "<img src='images/checkbox_no.png' width='16' height='16' alt='Selected' />"

	###
	@example add onSetCheckbox
	$tableView.onSetCheckbox checkboxKey,value
	@param [String] checkbox_key to identify the checkbox key
	@param [String] value to identify the value of checkbox
  ###
	onSetCheckbox: (checkbox_key, value) =>
		##|
		##|  By default this is a property
		# api.SetCheckbox window.currentProperty.id, checkbox_key, value
		console.log "onSetCheckbox(", checkbox_key, ",", value, ")"

	###
  @example to get the size of table row
  	tableView.size()
  @return [Integer] the length of the rows in table
	###
	size : () =>
		return @rowData.length

	###
  returns the number of rows checked
  @example
		tableView.numberChecked()
	@return [Integer] the number of rows that are checked
	###
	numberChecked: () =>
		total = 0
		for i, o of @rowData
			if o.checked then total++
		total

	###
  Initialize the class by sending in the ID of the tag you want to become a managed table.
  This should be a simple <table id='something'> tag.
  @example
		tableView.numberChecked()
	@param elTableHolder [jQuery Element] the $() referenced element that will hold the table
  @param showCheckbox [boolean] weather to show checkbox as first column
	###
	constructor: (@elTableHolder, @showCheckboxes) ->

		#@property Array list of columns as array
		@colList        = []
		#@property Array list of rows as array
		@rowData        = []
		#@property boolean|function sorting function to apply on render
		@sort           = 0
		#@property boolean to show headers of table
		@showHeaders    = true
		#@property boolean to show textbox to filter data
		@showFilters	= true
		#@property boolean to enable inline sorting clicking on column
		@inlineSorting = false


		@currentFilters  = {}
		@rowDataElements = {}

		#@property boolean|function callback to call on context menu click
		@contextMenuCallbackFunction = 0
		#@property boolean|function add menu to context menu
		@contextMenuCallSetup        = 0

		if !@showCheckboxes?
			@showCheckboxes = false

		if (!@elTableHolder[0])
			console.log "Error: Table id #{@elTableHolder} doesn't exist"

		#@property Object current table configurations
		@tableConfig = {}
		#@property Object table database configuration
		@tableConfigDatabase = null

	###
  to add the join table with current rendered table
  @example
  	table.addJoinTable "county", null, "county"
  @param String tableName the table to add as join table from datamap
  @param Function|null columnReduceFunction function to filter the join table columns
  @param String sourceField column to find as common in both table
  @return boolean to ensure join added
	###
	addJoinTable: (tableName, columnReduceFunction, sourceField) =>

		columns = DataMap.getColumnsFromTable tableName, columnReduceFunction
		for col in columns
			if col.source != sourceField
				c = new TableViewCol tableName, col
				c.joinKey = sourceField
				c.joinTable = @primaryTableName
				c.inlineSorting = @inlineSorting
				@colList.push(c)

		true

	###
  to add the table in the view from datamap
  @example
  	tableView "zipcode",null,null
  @param String tableName name of the table inside datamap
  @param Function|null columnReduceFunction function to filter the column
  @param Function|null reduceFunction function to filter the data
  @return boolean
	###
	addTable: (tableName, @columnReduceFunction, @reduceFunction) =>

		@primaryTableName = tableName

		##|
		##|  Find the columns for the specific table name
		columns = DataMap.getColumnsFromTable(tableName, @columnReduceFunction)
		for col in columns
			c = new TableViewCol tableName, col
			c.inlineSorting = @inlineSorting
			@colList.push(c)


		##|
		##|  Get the data from that table
		@updateRowData()
		true

	###
  add support for inline sorting when clicking on the column header
  @example
  	tableView.addInlineSortingSupport()
	###
	addInlineSortingSupport: () =>
		@inlineSorting = true
		@colList.map (column) -> column.inlineSorting = true


	###
  to add the default table row click event
  @example
  	tableView.defaultRowClick = (rowData,eventObject) ->
  @param Object row the data of row in form object that is clicked
  @param Object the object of click event
  @return boolean weather event is succeed
	###
	defaultRowClick: (row, e) =>
		console.log "DEF ROW CLICK=", row, e
		false

	###
  Remove the checkbox for all items except those included in the bookmark array that comes from the server
  @example
  	tableView.resetChecked [1,2,3]
  @param Array bookmarkArray the array of key to consider as bookmark
  @return boolean
	###
	resetChecked : (bookmarkArray) =>

		for i, o of @rowData
			o.checked = false
			for x, y of bookmarkArray
				if y.key == o.checkbox_key
					o.checked = true

			key = o.key
			if o.checked
				$("#check_#{@gid}_#{key}").html @imgChecked
			else
				$("#check_#{@gid}_#{key}").html @imgNotChecked

		false

	###
  render the checkable row with checkbox as first column
  @example
  	tableView.renderCheckable dataRowObject
  @return String html the html of the row as string
	###
	renderCheckable : (obj) =>

		if typeof obj.rowOptionAllowCheck != "undefined" and obj.rowOptionAllowCheck == false
			return "<td class='checkable'>&nbsp;</td>";

		img = @imgNotChecked
		if obj.checked
			img = @imgChecked

		if @tableName == "property" and key == window.currentProperty.id
			html = "<td class='checkable'> &nbsp; </td>"
		else
			html = "<td class='checkable' id='check_#{@gid}_#{obj.key}'>" + img + "</td>"

		return html

	###
  set up events callback
  @example
  	tableView.setUpEvents (rowData,e)-> , (rowData,eventType)->
  @param Function rowCallback callback to execute at the row click
  @param Function rowMouseOver callback to execute at the mouse over|out event
	###
	setupEvents: (@rowCallback, @rowMouseover) =>

	###
  to setup event internally for the table
	###
	internalSetupMouseEvents: () =>
		@elTheTable.bind "click touchbegin", (e) =>

			e.preventDefault()
			e.stopPropagation()

			data = @findRowFromElement e.target

			result = false
			if not e.target.constructor.toString().match(/Image/)

				defaultResult = @defaultRowClick data, e
				if defaultResult == false

					##|
					##|  Don't call a row click callback for the image which
					##|  is the checkbox column
					if typeof @rowCallback == "function"
						result = @rowCallback data, e

				else

					return false

			if result == false

				##|
				##| Check to see if it's a checkbox row
				if data? and data.checked?
					data.checked = !data.checked
					key = data.key
					if data.checked
						$("#check_#{@gid}_#{key}").html @imgChecked
					else
						$("#check_#{@gid}_#{key}").html @imgNotChecked

					# console.log "CHECKED BOX gid=", @gid, " key=", key, " table_key=", data.checkbox_key, " checked=", data.checked
					@onSetCheckbox data.checkbox_key, data.checked

			false
		## to test the mouseover callback
		@elTheTable.bind "mouseover mouseout", (e) =>
			e.preventDefault()
			e.stopPropagation()
			if typeof @rowMouseover == "function"
				data = @findRowFromElement e.target
				@rowMouseover data, if e.type is "mouseover" then "over" else "out"
			false

	###
  to add context menu with header column click
  @example
  	tableView.setupContextMenu (coordinates,data) ->
  @param Function contextMenuCallbackFunction function to execute on the click of context menu item
	###
	setupContextMenu: (@contextMenuCallbackFunction) =>

		if @contextMenuCallSetup == 1 then return true
		@contextMenuCallSetup = 1

		@elTableHolder.on "contextmenu", (e) =>

			e.preventDefault()
			e.stopPropagation()

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

	###
  Internal function called to setup the context menu on the header
	###
	setupContextMenuHeader: =>
		@setupContextMenu @contextMenuCallbackFunction

	###
  Table cache name is set, this allows saving/loading table configuration
  @param String tableCacheName the cache name to attach with table
	###
	setTableCacheName: (@tableCacheName) =>


	###
  internal function to apply sorting on table with column and sorting type
  @param Object column column on which sorting should be applied
  @param String type it can be ASC|DESC
	###
	applySorting: (column, type = 'ASC' ) =>
		## | update rows if new data added
		if( @rowData.length != DataMap.getValuesFromTable(@primaryTableName).length)
			@updateRowData()
			for counter, i of @rowData
				##| if row is not present for that data, render new row
				if !@elTheTable.find("tr [data-path^='/#{@primaryTableName}/#{i.key}/']").length
					@elTheTable.find('tbody').prepend(@renderRow(_previousRowsCount++,i,true))

		##| define sorter function using jquery tr switching
		_sorter = (conditions) =>
			_table = $("#table#{@gid}")
			_rows = _table.find('tbody tr')
			_rows.sort (a, b) ->
				keyA = $(a).find(".#{column.col.extraClassName}").text()
				keyB = $(b).find(".#{column.col.extraClassName}").text()
				if $(a).find(".#{column.col.extraClassName}").hasClass("dt_decimal")
					keyA = parseFloat keyA
					keyB = parseFloat keyB
				return conditions keyA,keyB
			$.each _rows, (index, row) ->
				_table.children("tbody").append(row)

		if type == 'ASC'
			_sorter (a,b) ->
				if a > b then return 1;
				if a < b then return -1;
				return 0
		else
			_sorter (a,b) ->
				if a < b then return 1;
				if a > b then return -1;
				return 0

	###
	Internal function called when there is a right click context menu event on a header column.   This will display the column options.
	###
	onContextMenuHeader: (coords, column) =>

		console.log "COORDS=", coords
		_c = @colList.filter (_column) =>
			return _column.col.name is column
		.pop()
		##| if column is sortable in dataTypes
		if _c.col.sortable
			_popupMenu = new PopupMenu "Column: #{column}", coords.x-150, coords.y



			##| add sorting menu item
			_popupMenu.addItem "Sort Ascending", () =>
				_popupMenu.closeTimer()
				@applySorting(_c)
			_popupMenu.addItem "Sort Descending", () =>
				_popupMenu.closeTimer()
				@applySorting(_c,'DSC')

		if typeof @tableCacheName != "undefined" && @tableCacheName != null
			if !_popupMenu
				_popupMenu = new PopupMenu "Column: #{column}", coords.x-150, coords.y
			_popupMenu.addItem "Configure Columns", (coords, data) =>
				@onConfigureColumns
					x: coords.x
					y: coords.y


	###
  Display a popup to adjust the columns of the table
  @example
  	tableView.onConfigureColumns x:200
  		y:300
  @param Object coords coordinates x and y where to show the menu
	###
	onConfigureColumns: (coords) =>

		popup = new PopupWindowTableConfiguration "Configure Columns", coords.x-150, coords.y
		popup.show(this)


	###
  function to filter rows If return's true, then the row is skipped
  @example
  	tableView.filterFunction (row)->
  @param Object row the current row which is in the process
	###
	filterFunction : (row) =>
		return false

	### ------------------------------------------------------------------------------------------------------------------
	to update the row data on the screen if new data has been added in datamapper they can be considered here
	@example
  	tableView.updateRowData()
	###
	updateRowData: () =>
		##|
		##|  Get latest data from that table using dataMap
		@rowData = []
		data = DataMap.getValuesFromTable @primaryTableName, @reduceFunction
		for row in data
			if @showCheckboxes
				row.checkbox_key = @primaryTableName + "_" + row.key
				row.checked = false

			@rowData.push row

	### ------------------------------------------------------------------------------------------------------------------
	Set the holder element to go to the bottom of the screen
	###
	setHolderToBottom: () =>

		height = $(window).height()
		pos = @elTableHolder.position()

		newHeight = height - pos.top
		@elTableHolder.height(newHeight)
		# console.log "Window Height=", height, " Pos=", pos, "NewHeight=", newHeight

		##|
		##|  If the width of the table scrolls, this fixes it
		width = @elTableHolder.width()
		console.log "W=", width
		console.log "I=", @elTableHolder.find(".inner-container")
		console.log "W2=", @elTableHolder.find(".inner-container").width()
		if width > 0
			@elTableHolder.find(".inner-container").width(width)

		true


	### ------------------------------------------------------------------------------------------------------------------
	make the table with fixed header and scrollable
	###
	fixedHeaderAndScrollable: (@fixedHeader = true) ->

	### ------------------------------------------------------------------------------------------------------------------
	function to render the added table inside the table holder element
	@example
	tableView.render()
	###
	render: () =>

		@rowDataElements = {}

		##|
		##|  Create a unique ID for the table, that doesn't change
		##|  even if the table is re-drawn
		if !@gid?
			@gid = GlobalValueManager.NextGlobalID()

		html = "";
		##| if fixed header and resizable
		if @fixedHeader

			if !@showHeaders
				throw new Error "fixed header can't be done without header"

			html += """
				<div class='table-wrapper' id='tableWrapper#{@gid}'><div class='outer-container'>
					<div class='inner-container'>
						<div class='table-header'>
							<table id="tableheader#{@gid}" class="tableview">
				"""

		else

			##|
			##|  draw the table header
			html += "<div class='tableviewSimpleWrapper'>"
			html += "<table class='tableview' id='table#{@gid}'>"

		##|
		##|  Add headers
		if @showHeaders

			html += "<thead><tr>";

			##|
			##|  Add a checkbox to the table that is persistant
			if @showCheckboxes
				html += "<th class='checkable'>&nbsp;</th>"

			for i in @colList
				html += i.RenderHeader(i.extraClassName);

			html += "</tr>";

		if @showFilters

			html += "<thead><tr>";

			##|
			##|  Add a checkbox to the table that is persistant
			if @showCheckboxes
				html += "<th class='checkable'>&nbsp;</th>"

			for i in @colList
				if i.visible
					html += "
						<td class='dataFilterWrapper'>
						<input class='dataFilter #{i.col.formatter.name}' data-path='/#{i.tableName}/#{i.col.source}'>
						</td>
					"

			html += "</tr>";

		##|
		##|  Start adding the body
		html += "</thead>"
		if @fixedHeader
			html += """</table>
            		</div>
								<div class="table-body">
									<table id='table#{@gid}' class="tableview">"""

		html += "<tbody id='tbody#{@gid}'>";

        # ---- html += DataMap.renderField "div", "zipcode", "city", "03105"

		# counter = 0
		if (typeof @sort == "function")
			@rowData.sort @sort

		##| if no row found then default message
		if @rowData.length is 0
			@addMessageRow "No results"

		for counter, i of @rowData

			# if @filterFunction i then continue

			if typeof i == "string"
				html += "<tr class='messageRow'><td class='messageRow' colspan='#{@colList.length+1}'"
				html += ">#{i}</td></tr>";
			else
				html += @renderRow(counter,i)

		html += "</tbody></table>";
		if @fixedHeader
			html += "</div></div></div></div>"
			#| add width to individual td
		else
			html += "</div>"

		@elTheTable = @elTableHolder.html(html);

		##|
		##|  If the holder element has no height defined and we have a fixed header
		##|  set the holder element to fill to bottom
		if @elTableHolder.height() == 0 and @fixedHeader
			@setHolderToBottom()

		##| if the fixed header add the width to first row td
		if @fixedHeader
			_html = "";
			$("#tableheader#{@gid} tr:first th").each (index,e) =>
				_html += "<col width='"+$(e).outerWidth()+"px' />"
			$("#table#{@gid}").append _html
			_tableHolder = @elTableHolder
			@elTableHolder.find(".table-body").scroll (e)->
				_tableHolder.find(".table-header").css('left',(-1*this.scrollLeft) + 'px')

		setTimeout () =>
			# globalResizeScrollable();
			if setupSimpleTooltips?
				setupSimpleTooltips();
		, 1

		##|
		##|  This is a new render which means we need to re-establish any context menu
		@contextMenuCallSetup = 0
		# @setupContextMenuHeader()
		@internalSetupMouseEvents()

		if @showFilters
			@elTheTable.find("input.dataFilter").on "keyup", @filterKeypress

		if @inlineSorting
			@bindInlineSortingEvents()

		true


	###
  internal function to get the html of a single row
  @param Integer counter the position of the row
  @param Object dataElement the data element with key as property retrived from data mapper
  @return String html the html of the row
	###
	renderRow: (counter,i,isNewRow = false) =>
		##|
		##|  Create the "TR" tag
		html = "<tr class='trow #{if isNewRow then 'newDataRow' else ''}' data-id='#{counter}' "
		html += ">"

		##|
		##|  Add a checkbox column possibly and then render the
		##|  column using the column object.
		if @showCheckboxes
			html += @renderCheckable(i)

		for col in @colList
			if col.visible
				if col.joinKey?
					val = DataMap.getDataField col.joinTable, i.key, col.joinKey
					str = DataMap.renderField "td", col.tableName, col.col.source, val, col.col.extraClassName
				else
					str = DataMap.renderField "td", col.tableName, col.col.source, i.key, col.col.extraClassName

				html += str

		html += "</tr>";

	###
  function to sort the table based on column and type
  @example
  	tableView.sortByColumn "state","DESC"
  @param string name name of column to apply sorting on
  @param string type type of sorting it can be ASC|DESC
	###
	sortByColumn: (_name,_type = 'ASC') =>
		_this = this
		_table = $("#table#{@gid}")
		_sorters = _table.find '.table-sorter'
		_th = _table.find("th:contains(#{_name})").first()
		_sorters.each () ->
			$(this).parent().attr('data-current-sorting','none')
			$(this).removeClass('fa-sort-asc fa-sort-desc').addClass('fa-sort')
		_col = @colList.filter (_col) ->
			_col.col.name == _name
		.pop()
		if _type is 'ASC'
			_th.attr('data-current-sorting','ASC')
			_th.find('.fa').removeClass('fa-sort fa-sort-desc').addClass('fa-sort-asc')
		else
			_th.attr('data-current-sorting','DSC')
			_th.find('.fa').removeClass('fa-sort fa-sort-asc').addClass('fa-sort-desc')
		_this.applySorting(_col,_type)

	###
  internal function to bind the table header row click event which are called withing inlineSortingSupport
	###
	bindInlineSortingEvents: () =>
		_table = $("#table#{@gid}")
		_sorters = _table.find '.table-sorter'
		_this = this
		_sorters.each () ->
			_th = $(this).parent()
			_th.attr('data-current-sorting','none').css('cursor','pointer')
			_th.on 'click', () ->
				_currentSorting = $(this).attr('data-current-sorting')
				_type = if _currentSorting is 'ASC' then 'DSC' else 'ASC'
				_this.sortByColumn($(this).text(),_type)

	###
  internal event Key press in a filter field, that executes during the filter text box keypress event
	###
	filterKeypress: (e) =>

		parts      = $(e.target).attr("data-path").split /\//
		tableName  = parts[1]
		columnName = parts[2]

		if !@currentFilters[tableName]?
			@currentFilters[tableName] = {}

		@currentFilters[tableName][columnName] = $(e.target).val()
		console.log "VAL=", @currentFilters[tableName]
		@applyFilters()

		return true

	###
  Apply the filters stored in "currentFilters" to each column and show/hide the rows
	###
	applyFilters: () =>

		filters = {}
		if( @rowData.length != DataMap.getValuesFromTable(@primaryTableName).length)
			_previousRowsCount = @rowData.length
			@updateRowData()
		for counter, i of @rowData
			keepRow = true

			if @currentFilters[i.table]
				for col in @colList
					if !@currentFilters[i.table][col.col.source]? then continue

					if !filters[i.table+col.col.source]
						filters[i.table+col.col.source] = new RegExp( @currentFilters[i.table][col.col.source] , "i");

					aa = DataMap.getDataField(i.table, i.key, col.col.source)
					if !filters[i.table+col.col.source].test aa
						keepRow = false

			_removeNewRowClass = (_html) =>
				setTimeout () =>
					_key = $(_html).data 'id'
					@elTheTable.find("tr[data-id=#{_key}]").removeClass 'newDataRow'
				,3000

			##| if row is not present for that data, render new row
			if !@elTheTable.find("tr [data-path^='/#{@primaryTableName}/#{i.key}/']").length
				_html = @renderRow(_previousRowsCount,i,true)
				@elTheTable.find('tbody').prepend(_html)
				_removeNewRowClass _html
				_previousRowsCount++


			if !@rowDataElements[counter]
				@rowDataElements[counter] = @elTheTable.find("tr[data-id='#{counter}']")

			if keepRow
				@rowDataElements[counter].show()
			else
				@rowDataElements[counter].hide()

		true

	###
  Add a row that takes the full width using colspan
	###
	addMessageRow : (message) =>
		@rowData.push message
		return 0;

	###
  clear the table using jquery .html ""
  @example
  	tableView.clear() will remove all the html of table
	###
	clear : =>
		@elTableHolder.html ""

	###
  clear the html and also remove the associated column and rows reference
  @example
  	tableView.reset()
	###
	reset: () =>
		@elTableHolder.html ""
		@rowData = []
		@colList = []
		true

	###
  add custom filter function which will be called on the key press of filter field
  @param Function callback to be called in keypress
	###
	setFilterFunction: (filterFunction) =>

		@filterFunction = filterFunction

		##|
		##|  Force the table to redraw with a global "redrawTables" command
		GlobalValueManager.Watch "redrawTables", () =>
			@render()

	###
  internal function to find the row Element from the event object
	###
	findRowFromElement: (e, stackCount) =>

		# console.log "FindRowFromElement:", e, stackCount

		if typeof stackCount == "undefined" then stackCount = 0
		if stackCount > 4 then return null
		data_id = $(e).attr("data-id")
		if data_id then return @rowData[data_id]
		parent = $(e).parent()
		if parent then return @findRowFromElement(parent, stackCount + 1)
		return null

	###
  add responsive capabilities by adding auto hide columns having width less than passed thresold
  @param Integer width default is 32 so columns having width less than 32 will be hidden if space is not enough
	###
	setAutoHideColumn: (width=32) =>
		_handleResize = =>
			_headerHideIndexes = [];
			##| reset table to calculate based on updated width
			@elTableHolder.find("tr").each () ->
				$(this).find("th,td").removeClass('hide')

			@elTableHolder.find("thead tr:first th").each () ->
				if $(this).outerWidth() < width
					_headerHideIndexes.push($(this).index())
			##| make sure to have hide left columns first
			while _headerHideIndexes.length
				_index = _headerHideIndexes.pop();
				if @elTableHolder.find("tr th:eq(#{_index})").outerWidth() < width
					@elTableHolder.find("tr").each () ->
						$(this).find("th:eq(#{_index}),td:eq(#{_index})").addClass('hide')
		_handleResize()
		$(window).on 'resize', _handleResize



