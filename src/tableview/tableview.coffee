## -------------------------------------------------------------------------------------------------------------
## A Table manager class that is designed to quickly build scrollable tables
##
## @example new TableView $(".tableHolder")
##
class TableView

	# @property [String] imgChecked html to be used when checkbox is checked
	imgChecked     : "<img src='images/checkbox.png' width='16' height='16' alt='Selected' />"

	# @property [String] imgNotChecked html to be used when checkbox is not checked
	imgNotChecked  : "<img src='images/checkbox_no.png' width='16' height='16' alt='Selected' />"

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

		# @property [Boolean] to enable inline sorting clicking on column
		@inlineSorting = false

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
				c.joinKey = sourceField
				c.joinTable = @primaryTableName
				c.inlineSorting = @inlineSorting
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

	## -------------------------------------------------------------------------------------------------------------
	## add support for inline sorting when clicking on the column header
	##
	addInlineSortingSupport: () =>
		@inlineSorting = true
		@colList.map (column) -> column.inlineSorting = true

	## -------------------------------------------------------------------------------------------------------------
	## to add the default table row click event
	##
	## @param [Object] row the data of row in form object that is clicked
	## @param [Event] the clicked jquery event object
	## @event defaultRowClick
	## @return [Boolean]
	##
	defaultRowClick: (row, e) =>
		console.log "DEF ROW CLICK=", row, e
		false

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

	## -------------------------------------------------------------------------------------------------------------
	## render the checkable row with checkbox as first column
	##
	## @return [String] html the html of the row as string
	##
	renderCheckable : (obj) =>
		console.log obj
		if typeof obj.rowOptionAllowCheck != "undefined" and obj.rowOptionAllowCheck == false
			return "<td class='checkable'>&nbsp;</td>";

		img = @imgNotChecked
		if obj.checked
			img = @imgChecked

		if @tableName == "property" and key == window.currentProperty.id
			html = "<td class='checkable'> &nbsp; </td>"
		else
			html = "<td class='checkable' id='check_#{@gid}_#{obj.id}'>" + img + "</td>"

		return html

	## -------------------------------------------------------------------------------------------------------------
	## set up events callback
	##
	## @example
	## 		tableview.setupEvents (rowData,e) -> , (rowData,eventType) ->
	## @param [Function] rowCallback callback to execute at the row click
	## @param [Function] rowMouseover callback to execute at the mouse over|out event
	##
	setupEvents: (@rowCallback, @rowMouseover) =>

	## -------------------------------------------------------------------------------------------------------------
	## to setup event internally for the table
	##
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
					key = data.id
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

	## -------------------------------------------------------------------------------------------------------------
	## function to set context menu on header
	##
	setupContextMenuHeader: =>
		@setupContextMenu @contextMenuCallbackFunction

	## -------------------------------------------------------------------------------------------------------------
	## Table cache name is set, this allows saving/loading table configuration
	##
	## @param [String] tableCacheName the cache name to attach with table
	##
	setTableCacheName: (@tableCacheName) =>

	## -------------------------------------------------------------------------------------------------------------
	## internal function to apply sorting on table with column and sorting type
	##
	## @param [Object] column column on which sorting should be applied
	## @param [String] type it can be ASC|DESC
	##
	internalApplySorting: (column, type = 'ASC' ) =>
		## | update rows if new data added
		if( @rowData.length != DataMap.getValuesFromTable(@primaryTableName).length)
			@updateRowData()
			for counter, i of @rowData
				##| if row is not present for that data, render new row
				if !@elTheTable.find("tr [data-path^='/#{@primaryTableName}/#{i.id}/']").length
					@elTheTable.find('tbody').prepend(@internalRenderRow(counter++,i,true))

		##| define sorter function using jquery tr switching
		sorter = (conditions) =>
			table = $("#table#{@gid}")
			rows = table.find('tbody tr')
			rows.sort (a, b) ->
				keyA = $(a).find(".#{column.col.extraClassName}").text()
				keyB = $(b).find(".#{column.col.extraClassName}").text()
				if $(a).find(".#{column.col.extraClassName}").hasClass("dt_decimal")
					keyA = parseFloat keyA
					keyB = parseFloat keyB
				return conditions keyA,keyB
			$.each rows, (index, row) ->
				table.children("tbody").append(row)

		if type == 'ASC'
			sorter (a,b) ->
				if a > b then return 1;
				if a < b then return -1;
				return 0
		else
			sorter (a,b) ->
				if a < b then return 1;
				if a > b then return -1;
				return 0

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
				@internalApplySorting(selectedColumn)
			popupMenu.addItem "Sort Descending", () =>
				popupMenu.closeTimer()
				@internalApplySorting(selectedColumn,'DSC')
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
	## function to filter rows if return's true, then the row is skipped
	##
	## @param [Object] row the current row for which the funciton is called
	## @return [Boolean]
	##
	filterFunction : (row) =>
		return false

	## -------------------------------------------------------------------------------------------------------------
	## function to update row data on the screen if new data has been added in datamapper they can be considered
	##
	updateRowData: () =>
		##|
		##|  Get latest data from that table using dataMap
		@rowData = []
		data = DataMap.getValuesFromTable @primaryTableName, @reduceFunction
		for row in data
			if @showCheckboxes
				row.checkbox_key = @primaryTableName + "_" + row.id
				row.checked = false

			@rowData.push row

	## -------------------------------------------------------------------------------------------------------------
	## set the holder element to go to the bottom of the screen
	##
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

	## -------------------------------------------------------------------------------------------------------------
	## make the table with fixed header and scrollable
	##
	## @param [Boolean] fixedHeader if header is fixed or not
	##
	fixedHeaderAndScrollable: (@fixedHeader = true) ->

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
					return column.col.source is colName
		if ! col.length
			throw new Error "column with name or source #{colName} is not found"
		col = col.pop()
		@internalCountNumberOfOccurenceOfPopup(col,true)

	## -------------------------------------------------------------------------------------------------------------
	## internal function to calculate the number of occurences for each value in options
	##
	## @param [Object] col the whole column object
	## @param [Boolean] initialize if table has been rendered or not
	##
	internalCountNumberOfOccurenceOfPopup: (col,initialize = false) =>

		##| calculate occurances of unique values
		occurences = @rowData.map (r) => {key: r.id, value : DataMap.getDataField col.tableName, r.id, col.col.source}
		counts = {}
		occurences.forEach (v) =>
			if $("#tbody#{@gid}").find("[data-id=#{v.id}]").is(":visible") or initialize
				if counts[v.value] then counts[v.value]++ else counts[v.value] = 1
		occurences = undefined
		col.filterPopupData = counts

		if @filterAsPopupCols and typeof @filterAsPopupCols == 'object'
			@filterAsPopupCols[col.col.source] = col
		else
			@filterAsPopupCols =
				"#{col.col.source}" : col

	## -------------------------------------------------------------------------------------------------------------
	## function to make column customizable in the popup
	##
	## @example
	##		table.allowCustomize()
	## @param [Boolean] customizableColumns
	##
	allowCustomize: (@customizableColumns = true) ->


	## -------------------------------------------------------------------------------------------------------------
	## function to render the added table inside the table holder element
	##
	## @example tableview.render()
	## @return [Boolean]
	##
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

			popupCols = []
			if typeof @filterAsPopupCols is 'object' then popupCols = Object.keys @filterAsPopupCols
			for i in @colList
				if i.visible
					html += "<td class='dataFilterWrapper'>"
					if popupCols.indexOf(i.col.source) == -1
						html += "<input class='dataFilter #{i.col.formatter.name}' data-path='/#{i.tableName}/#{i.col.source}'>"
					else
						html += "<a class='link filterPopupCol' data-source='#{i.col.source}' style='width:100%;height:100%;display:block;text-align:center;font-size:14px;border:1px solid #000' href='javascript:;'><span class='filtered_text'>Select</span></a><span class='caret pull-right' style='margin-top:-12px;margin-right:10px;'></span>"

					html += "</td>"

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
				html += @internalRenderRow(counter,i)

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
			html = "";
			$("#tableheader#{@gid} tr:first th").each (index,e) =>
				html += "<col width='"+$(e).outerWidth()+"px' />"
			$("#table#{@gid}").append html
			tableHolder = @elTableHolder
			@elTableHolder.find(".table-body").scroll (e)->
				tableHolder.find(".table-header").css('left',(-1*this.scrollLeft) + 'px')

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
			@elTheTable.find("input.dataFilter").on "keyup", @onFilterKeypress
			@elTheTable.find("a.filterPopupCol").on "click", @onFilterPopupClick



		if @inlineSorting
			@internalBindInlineSortingEvents()
		##| add default context menu for sorting as per #89 comment
		@setupContextMenu @contextMenuCallbackFunction

		true


	## -------------------------------------------------------------------------------------------------------------
	## internal function to get the html of a single row
	##
	## @param [Integer] counter the position of the row
	## @param [Object] dataElement the data element with key as property retrived from the data map
	## @return [String] html the html of the row
	##
	internalRenderRow: (counter,i,isNewRow = false) =>

		# console.log "Render #{counter} i=", i

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
					val = DataMap.getDataField col.joinTable, i.id, col.joinKey
					str = DataMap.renderField "td", col.tableName, col.col.source, val, col.col.extraClassName
				else
					str = DataMap.renderField "td", col.tableName, col.col.source, i.id, col.col.extraClassName

				html += str

		html += "</tr>";

	## -------------------------------------------------------------------------------------------------------------
	## function to sort the table base on column and type
	##
	## @param [String] name name of the column to apply sorting on
	## @param [String] type it can be ASC|DESC
	##
	sortByColumn: (name,type = 'ASC') =>
		that = this
		table = $("#table#{@gid}")
		sorters = table.find '.table-sorter'
		th = table.find("th:contains(#{name})").first()
		sorters.each () ->
			$(this).parent().attr('data-current-sorting','none')
			$(this).removeClass('fa-sort-asc fa-sort-desc').addClass('fa-sort')
		col = @colList.filter (col) ->
			col.col.name == name
		.pop()
		if type is 'ASC'
			th.attr('data-current-sorting','ASC')
			th.find('.fa').removeClass('fa-sort fa-sort-desc').addClass('fa-sort-asc')
		else
			th.attr('data-current-sorting','DSC')
			th.find('.fa').removeClass('fa-sort fa-sort-asc').addClass('fa-sort-desc')
		that.internalApplySorting(col,type)

	## -------------------------------------------------------------------------------------------------------------
	## internal function to bind the table header row click event which are called withing inlineSortingSupport
	##
	internalBindInlineSortingEvents: () =>
		table = $("#table#{@gid}")
		sorters = table.find '.table-sorter'
		that = this
		sorters.each () ->
			th = $(this).parent()
			th.attr('data-current-sorting','none').css('cursor','pointer')
			th.on 'click', () ->
				currentSorting = $(this).attr('data-current-sorting')
				type = if currentSorting is 'ASC' then 'DSC' else 'ASC'
				that.sortByColumn($(this).text(),type)

	## -------------------------------------------------------------------------------------------------------------
	## intenal event key press in a filter field, that executes during the filter text box keypress event
	##
	## @event onFilterKeypress
	## @param [Event] e jquery event keypress object
	## @return [Boolean]
	##
	onFilterKeypress: (e) =>

		parts      = $(e.target).attr("data-path").split /\//
		tableName  = parts[1]
		columnName = parts[2]

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
					@currentFilters[@filterAsPopupCols[source].tableName][@filterAsPopupCols[source].col.source] = option
					$(e.target).find('.filtered_text').text option
					@applyFilters()
			menu.addItem "Clear filter", (data) =>
				delete @currentFilters[@filterAsPopupCols[source].tableName][@filterAsPopupCols[source].col.source]
				$(e.target).find('.filtered_text').text 'select'
				@applyFilters()

	## -------------------------------------------------------------------------------------------------------------
	## Apply filters stored in "currentFilters" to each column and show/hide the rows
	##
	applyFilters: () =>

		filters = {}
		if( @rowData.length != DataMap.getValuesFromTable(@primaryTableName).length)
			previousRowsCount = @rowData.length
			@updateRowData()
		for counter, i of @rowData
			keepRow = true

			if @currentFilters[i.table]
				for col in @colList
					if !@currentFilters[i.table][col.col.source]? then continue

					if !filters[i.table+col.col.source]
						filters[i.table+col.col.source] = new RegExp( @currentFilters[i.table][col.col.source] , "i");

					aa = DataMap.getDataField(i.table, i.id, col.col.source)
					if !filters[i.table+col.col.source].test aa
						keepRow = false

			removeNewRowClass = (html) =>
				setTimeout () =>
					key = $(html).data 'id'
					@elTheTable.find("tr[data-id=#{key}]").removeClass 'newDataRow'
				,3000

			##| if row is not present for that data, render new row
			if !@elTheTable.find("tr [data-path^='/#{@primaryTableName}/#{i.id}/']").length
				html = @internalRenderRow(previousRowsCount,i,true)
				@elTheTable.find('tbody').prepend(html)
				removeNewRowClass html
				previousRowsCount++


			if !@rowDataElements[counter]
				@rowDataElements[counter] = @elTheTable.find("tr[data-id='#{counter}']")

			if keepRow
				@rowDataElements[counter].show()
			else
				@rowDataElements[counter].hide()

		popupCols = []
		if typeof @filterAsPopupCols is 'object' then popupCols = Object.keys @filterAsPopupCols
		popupCols.forEach (columnObj) =>
			column = @colList.filter (c) => c.col.source == columnObj
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
	## add custom filter function which will be called on the key press of filter field
	##
	## @param [Function] filterFunction to be called in keypress
	##
	setFilterFunction: (filterFunction) =>

		@filterFunction = filterFunction

		##|
		##|  Force the table to redraw with a global "redrawTables" command
		GlobalValueManager.Watch "redrawTables", () =>
			@render()

	## -------------------------------------------------------------------------------------------------------------
	## internal function to find the row element from the event object
	##
	## @param [Event] e the jquery Event object
	## @param [Integer] stackCount number of checking round
	##
	findRowFromElement: (e, stackCount) =>

		# console.log "FindRowFromElement:", e, stackCount

		if typeof stackCount == "undefined" then stackCount = 0
		if stackCount > 4 then return null
		data_id = $(e).attr("data-id")
		if data_id then return @rowData[data_id]
		parent = $(e).parent()
		if parent then return @findRowFromElement(parent, stackCount + 1)
		return null

	## -------------------------------------------------------------------------------------------------------------
	## add responsive capabilities by adding auto hide columns having width less than passed thresold
	##
	## @param [Integer] width default is 32 so column having width less than 32 will be hidden if space is not enough
	##
	setAutoHideColumn: (width=32) =>
		handleResize = =>
			headerHideIndexes = [];
			##| reset table to calculate based on updated width
			@elTableHolder.find("tr").each () ->
				$(this).find("th,td").removeClass('hide')

			@elTableHolder.find("thead tr:first th").each () ->
				if $(this).outerWidth() < width
					headerHideIndexes.push($(this).index())

			##| make sure to have hide left columns first
			while headerHideIndexes.length
				index = headerHideIndexes.pop();
				if @elTableHolder.find("tr th:eq(#{index})").outerWidth() < width
					@elTableHolder.find("tr").each () ->
						$(this).find("th:eq(#{index}),td:eq(#{index})").addClass('hide')
		handleResize()
		@elTableHolder.parent().on 'resize', handleResize
		$(window).on 'resize', handleResize
