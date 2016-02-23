##
##  A Table manager class that is designed to quickly build scrollable tables
##
##  @class TableView
##  @uses iScroll5

class TableView

	imgChecked     : "<img src='images/checkbox.png' width='16' height='16' alt='Selected' />"
	imgNotChecked  : "<img src='images/checkbox_no.png' width='16' height='16' alt='Selected' />"

	##|
	##| Checkboxes
	onSetCheckbox: (checkbox_key, value) =>
		##|
		##|  By default this is a property
		# api.SetCheckbox window.currentProperty.id, checkbox_key, value
		console.log "onSetCheckbox(", checkbox_key, ",", value, ")"

	size : () =>
		return @rowData.length

	numberChecked: () =>
		total = 0
		for i, o of @rowData
			if o.checked then total++
		total

	##| Initialize the class by sending in the ID of the tag you want to become
	##| a managed table.   This should be a simple <table id='something'> tag.
	##|
	##| @param elTableHolder [jQuery Element] the $() referenced element that will hold the table
	##|
	constructor: (@elTableHolder, @showCheckboxes) ->

		@colList        = []
		@rowData        = []
		@sort           = 0
		@showHeaders    = true
		@showFilters	= true

		##|
		##|  Search filters
		@currentFilters  = {}
		@rowDataElements = {}

		##|
		##|  No context menu setup by default
		@contextMenuCallbackFunction = 0
		@contextMenuCallSetup        = 0

		if !@showCheckboxes?
			@showCheckboxes = false

		if (!@elTableHolder[0])
			console.log "Error: Table id #{@elTableHolder} doesn't exist"

		@tableConfig = {}
		@tableConfigDatabase = null

	addJoinTable: (tableName, columnReduceFunction, sourceField) =>

		columns = DataMap.getColumnsFromTable tableName, columnReduceFunction
		for col in columns
			if col.source != sourceField
				c = new TableViewCol tableName, col
				c.joinKey = sourceField
				c.joinTable = @primaryTableName
				@colList.push(c)

		true

	addTable: (tableName, columnReduceFunction, reduceFunction) =>

		@primaryTableName = tableName

		##|
		##|  Find the columns for the specific table name
		columns = DataMap.getColumnsFromTable(tableName, columnReduceFunction)
		for col in columns
			c = new TableViewCol tableName, col
			@colList.push(c)


		##|
		##|  Get the data from that table
		data = DataMap.getValuesFromTable tableName, reduceFunction
		for row in data
			if @showCheckboxes
				row.checkbox_key = tableName + "_" + row.key
				row.checked = false

			@rowData.push row

		true

	##|
	##|  Default callback for a row that is clicked
	defaultRowClick: (row, e) =>
		console.log "DEF ROW CLICK=", row, e
		false

	##|
	##|  Remove the checkbox for all items except those included
	##|  in the bookmark array that comes from the server
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

	setupEvents: (@rowCallback, @rowMouseover) =>

	internalSetupMouseEvents: () =>

		@elTheTable.find("tr td").bind "click touchbegin", (e) =>

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
				console.log "data=", data
				if data.checked?
					data.checked = !data.checked
					key = data.key
					if data.checked
						$("#check_#{@gid}_#{key}").html @imgChecked
					else
						$("#check_#{@gid}_#{key}").html @imgNotChecked

					# console.log "CHECKED BOX gid=", @gid, " key=", key, " table_key=", data.checkbox_key, " checked=", data.checked
					@onSetCheckbox data.checkbox_key, data.checked

			false

		@elTheTable.find("tr td").bind "mouseover", (e) =>
			e.preventDefault()
			e.stopPropagation()
			if typeof @rowMouseover == "function"
				data = @findRowFromElement e.target
				@rowMouseover data, "over"
			false

		@elTheTable.find("tr td").bind "mouseout", (e) =>
			e.preventDefault()
			e.stopPropagation()
			if typeof @rowMouseover == "function"
				data = @findRowFromElement e.target
				@rowMouseover data, "out"
			false

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

	##|
	##|  Internal function called to setup the context menu on the header
	setupContextMenuHeader: =>
		@setupContextMenu @contextMenuCallbackFunction

	##|
	##|  Table cache name is set, this allows saving/loading table configuration
	setTableCacheName: (@tableCacheName) =>


	##|
	##|  Internal function called when there is a right click context menu event
	##|  on a header column.   This will display the column options.
	##|
	onContextMenuHeader: (coords, column) =>

		console.log "COORDS=", coords
		_c = @colList.filter (_column) =>
			return _column.col.name is column
		.pop()

		##| if column is sortable in dataTypes
		if _c.col.sortable
			_popupMenu = new PopupMenu "Column: #{column}", coords.x-150, coords.y

			##| define sorter function using jquery tr switching
			_sorter = (conditions) =>
				_table = $("#table#{@gid}")
				_rows = _table.find('tbody tr')
				_popupMenu.closeTimer()
				_rows.sort (a, b) ->
					keyA = $(a).find(".#{_c.col.extraClassName}").text()
					keyB = $(b).find(".#{_c.col.extraClassName}").text()
					if $(a).find(".#{_c.col.extraClassName}").hasClass("dt_decimal")
						keyA = parseFloat keyA
						keyB = parseFloat keyB
					return conditions keyA,keyB
				$.each _rows, (index, row) ->
					_table.children("tbody").append(row)

			##| add sorting menu item
			_popupMenu.addItem "Sort Ascending", () =>
				return _sorter (a,b)->
					if a > b then return 1;
					if a < b then return -1;
					return 0
			_popupMenu.addItem "Sort Descending", () ->
				return _sorter (a,b)->
					if a < b then return 1;
					if a > b then return -1;
					return 0

		if typeof @tableCacheName != "undefined" && @tableCacheName != null
			if !_popupMenu
				_popupMenu = new PopupMenu "Column: #{column}", coords.x-150, coords.y
			_popupMenu.addItem "Configure Columns", (coords, data) =>
				@onConfigureColumns
					x: coords.x
					y: coords.y


	##|
	##|  Display a popup to adjust the columns of the table
	onConfigureColumns: (coords) =>

		popup = new PopupWindowTableConfiguration "Configure Columns", coords.x-150, coords.y
		popup.show(this)


	##|
	##|  If return's true, then the row is skipped
	filterFunction : (row) =>
		return false

	render: () =>

		@rowDataElements = {}

		##|
		##|  Create a unique ID for the table, that doesn't change
		##|  even if the table is re-drawn
		if !@gid?
			@gid = GlobalValueManager.NextGlobalID()

		##|
		##|  draw the table header
		html = "<table class='tableview' id='table#{@gid}'>"

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
		html += "<tbody id='tbody#{@gid}'>";

        # ---- html += DataMap.renderField "div", "zipcode", "city", "03105"

		# counter = 0
		if (typeof @sort == "function")
			@rowData.sort @sort

		for counter, i of @rowData

			# if @filterFunction i then continue

			if typeof i == "string"
				html += "<tr class='messageRow'><td class='messageRow' colspan='#{@colList.length+1}'"
				html += ">#{i}</td></tr>";
			else
				##|
				##|  Create the "TR" tag
				html += "<tr class='trow' data-id='#{counter}' "
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

		html += "</tbody></table>";

		@elTheTable = @elTableHolder.html(html);

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

		true

	##|
	##|  Key press in a filter field
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

	##|
	##| Apply the filters stored in "currentFilters" to each
	##| column and show/hide the rows
	applyFilters: () =>

		filters = {}
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

			if !@rowDataElements[counter]
				@rowDataElements[counter] = @elTheTable.find("tr[data-id='#{counter}']")

			if keepRow
				@rowDataElements[counter].show()
			else
				@rowDataElements[counter].hide()

		true

	##
	## Add a row that takes the full width
	addMessageRow : (message) =>
		@rowData.push message
		return 0;

	clear : =>
		@elTableHolder.html ""

	reset: () =>
		@elTableHolder.html ""
		@rowData = []
		@colList = []
		true

	setFilterFunction: (filterFunction) =>

		@filterFunction = filterFunction

		##|
		##|  Force the table to redraw with a global "redrawTables" command
		GlobalValueManager.Watch "redrawTables", () =>
			@render()

	findRowFromElement: (e, stackCount) =>

		# console.log "FindRowFromElement:", e, stackCount

		if typeof stackCount == "undefined" then stackCount = 0
		if stackCount > 4 then return null

		data_id = $(e).attr("data-id")
		if data_id then return @rowData[data_id]
		parent = $(e).parent()
		if parent then return @findRowFromElement(parent, stackCount + 1)
		return null

	setAutoHideColumn: (width=32) =>
		_handleResize = =>
			_headerHideIndexes = [];
			##| reset table to calculate based on updated width
			@elTableHolder.find("tr").each () ->
				$(this).find("th,td").removeClass('hide')

			@elTableHolder.find("thead tr:first th").each () ->
				if $(this).outerWidth() < width
					_headerHideIndexes.push($(this).index())
			console.log _headerHideIndexes
			##| make sure to have hide left columns first
			while _headerHideIndexes.length
				_index = _headerHideIndexes.pop();
				if @elTableHolder.find("tr th:eq(#{_index})").outerWidth() < width
					@elTableHolder.find("tr").each () ->
						$(this).find("th:eq(#{_index}),td:eq(#{_index})").addClass('hide')
		_handleResize()
		$(window).on 'resize', _handleResize



