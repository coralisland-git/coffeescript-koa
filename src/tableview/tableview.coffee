##
##  A Table manager class that is designed to quickly build scrollable tables
##
##  @class TableView
##  @uses iScroll5

class TableView

	imgChecked     : "<img src='images/checkbox.png' width='16' height='16' alt='Selected' />"
	imgNotChecked  : "<img src='images/checkbox_no.png' width='16' height='16' alt='Selected' />"

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
	##| @param tableName [string] optional name of the source table for checkboxes
	##| @param keyColum [string] optional column name for the unique id in the database
	##|
	constructor: (@elTableHolder, @tableName, @keyColumn) ->
		@colList     = []
		@rowData     = []
		@sort        = 0
		@tableHeight = 0
		@showHeaders = true

		##|
		##|  No context menu setup by default
		@contextMenuCallbackFunction = 0
		@contextMenuCallSetup = 0

		if (!@elTableHolder[0])
			console.log "Error: Table id #{@elTableHolder} doesn't exist"

		@tableConfig = {}
		@tableConfigDatabase = null
		@basePath = 0

	##|
	##|  Set the base path for each cell of data to follow
	setBasePath: (@basePath) =>
		window.db.watch "#{@basePath}/", @onSocketChangeNotification

	onSocketChangeNotification: (path, data) =>

		for i in @rowData
			if path.startsWith "#{@basePath}/#{i["id"]}/"
				field = path.replace "/#{@basePath}/#{i["id"]}/", ""
				# console.log "received update on field [", field, "] to [", data, "] for id=", i.id
				if typeof i[field] != "undefined"
					i[field] = data
					@render()

				return

	##|
	##|  Given an array of column configuration structures, create new
	##|  columns automatically based on the configuration.
	##|  Example:
	## name       : 'Create Date'
	## source     : 'create_date'
	## visible    : true
	## hideable   : true
	## editable   : true
	## type       : 'datetime'
	## required   : false
	configureColumns: (columns, @tableCacheName) =>

		for col in columns

			c = new TableViewCol col.source, col.name

			##|
			##|  Check for an override in the config
			# customValue = user.tableConfigGetColumnVisible(@tableCacheName, c.name)
			# if customValue != null
			# 	col.visible = customValue

			##|
			##|  Tooltip, if specified, is shown when you hover over the column
			c.tooltip  = col.tooltip
			c.visible  = col.visible
			c.editable = col.editable
			c.options  = col.options

			c.initFormat col.type, col.options

			# formatter = c.initFormat col.type, col.options

			# if col.limit and col.limit > 0 and col.limit < 30
			# 	if formatter.width == null
			# 		formatter.setWidth "#{col.limit * 8}px"

			##|
			##| Optional render function on the column
			# if typeof col.render == "function"
			# 	formatter.displayFormat = col.render

			# ##|
			# ##| Optional width setting
			# if typeof col.width == "number"
			# 	formatter.setWidth(col.width + "px");

			@colList.push(c)

		@rowCallback = @defaultRowClick

		##|
		##| Setup an event to watch for table configuration changes
		$("body").on "tableConfig", (e) =>
			##|
			##|  Update for table config received
			console.log "Received TableConfig: ", @tableCacheName
			changed = false;

			# for i in @colList
			# 	customValue = user.tableConfigGetColumnVisible(@tableCacheName, i.name)
			# 	if customValue != null
			# 		if i.visible != customValue
			# 			changed = true
			# 			i.visible = customValue

			if changed
				@render()

		true

	##|
	##|  Default callback for a row that is clicked
	defaultRowClick: (row, e) =>

		console.log "DEF ROW CLICK=", row, e

		if /editable/.test e.target.className
			##|
			##|  Click on an editable field
			field_name = $(e.target).attr("f")
			if typeof field_name != "undefined"
				##|
				##| Edit this field
				for col in @colList
					if col.name == field_name
						attr = $(e.target).attr("data-path")
						coords = GlobalValueManager.GetCoordsFromEvent(e)
						col.showEditor coords.x, coords.y, row, attr, $(e.target)
						return true

		false

	onClickCheckbox : (key) =>
		for i in @rowData
			if i[@keyColumn] == key
				console.log "Found record", i, i.checked
				i.checked = i.checked != true
				console.log "Checked is now ", i.checked

				if i.checked
					$("#check_#{@tableName}_#{key}").html @imgChecked
				else
					$("#check_#{@tableName}_#{key}").html @imgNotChecked

				@onCheckbox(i)

	onCheckbox : (obj) =>
		checkBoxes = []
		for o in @rowData
			if o.checked then checkBoxes.push o[@keyColumn]
		true

	##|
	##|  Remove the checkbox for all items except those included
	##|  in the bookmark array that comes from the server
	resetChecked : (bookmarkArray) =>
		for i, o of @rowData
			o.checked = false
			for x, y of bookmarkArray
				if y.key == o.checkbox_key
					o.checked = true

			key = o[@keyColumn]
			if o.checked
				$("#check_#{@gid}_#{key}").html @imgChecked
			else
				$("#check_#{@gid}_#{key}").html @imgNotChecked

		false

	addRow : (obj) =>
		obj.checkbox_key = @tableName + "_" + obj[@keyColumn];

		if typeof obj.checked == "undefined"
			obj.checked = false

		if @cleanupFunction
			@cleanupFunction(obj)

		if window.currentProperty && window.currentProperty.bookmarks
			for o in window.currentProperty.bookmarks
				if o.key == obj.checkbox_key
					obj.checked = true

		@rowData.push(obj);

	renderCheckable : (obj) =>

		if typeof obj.rowOptionAllowCheck != "undefined" and obj.rowOptionAllowCheck == false
			return "<td class='checkable'>&nbsp;</td>";

		img = @imgNotChecked
		if obj.checked
			img = @imgChecked

		key = obj[@keyColumn]
		if @tableName == "property" and key == window.currentProperty.id
			html = "<td class='checkable'> &nbsp; </td>"
		else
			html = "<td class='checkable' id='check_#{@gid}_#{key}'>" + img + "</td>"

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
				if typeof data.checked != "undefined"
					data.checked = !data.checked
					key = data[@keyColumn]
					if data.checked
						$("#check_#{@gid}_#{key}").html @imgChecked
					else
						$("#check_#{@gid}_#{key}").html @imgNotChecked

					console.log "CHECKED BOX gid=", @gid, " key=", key, " table_key=", data.checkbox_key, " checked=", data.checked
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

	onSetCheckbox: (checkbox_key, value) =>
		##|
		##|  By default this is a property
		api.SetCheckbox window.currentProperty.id, checkbox_key, value

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
	##|  Internal function called when there is a right click context menu event
	##|  on a header column.   This will display the column options.
	##|
	onContextMenuHeader: (coords, column) =>

		popupMenu = new PopupMenu "Column: #{column}", coords.x-150, coords.y

		if typeof @tableCacheName != "undefined" && @tableCacheName != null
			popupMenu.addItem "Configure Columns", (coords, data) =>
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

	##|
	##|  If the table config has changed, re-render the table
	##|
	processTableConfig: () =>

		didChange = false
		for i in @colList
			if i.visible == true && @tableConfig[i.name] == false
				didChange = true
				i.visible = false

			if i.visible == false && @tableConfig[i.name] == true
				didChange = true
				i.visible = true

		if didChange
			@render()

		return didChange

	render: () =>

		##|
		##|  Cause the real rendering to happen in another thread
		setTimeout () =>
			@realRender()
		, 10
		return true

	realRender : () =>

		##|
		##|  Create a unique ID for the table, that doesn't change
		##|  even if the table is re-drawn
		if typeof @gid == "undefined"
			@gid = GlobalValueManager.NextGlobalID()

		@processTableConfig()

		##|
		##|  draw the table header
		html = "<table class='tableview' id='table#{@gid}'>"

		##|
		##|  Add headers
		if @showHeaders
			html += "<thead><tr>";

			if @keyColumn and @tableName
				html += "<th class='checkable'>&nbsp;</th>"

			for i in @colList
				html += i.RenderHeader();

			html += "</tr></thead>";

		##|
		##|  Start adding the body
		html += "<tbody id='tbody#{@gid}'>";

		counter = 0
		if (typeof @sort == "function")
			@rowData.sort @sort

		for counter, i of @rowData
			if @filterFunction i then continue

			if typeof i == "string"
				html += "<tr class='messageRow'><td class='messageRow' colspan='#{@colList.length+1}'"
				html += ">#{i}</td></tr>";
			else
				##|
				##|  Create the "TR" tag
				html += "<tr class='trow' data-id='#{counter}' "
				if typeof i.checkbox_key != "undefined" and typeof @tableName != "undefined" and @tableName != null
					html += "data-key='#{i.checkbox_key}'";
				if typeof i.metro_area != "undefined"
					html += "data-metro-area='#{i.metro_area}'"

				html += ">"

				##|
				##|  Add a checkbox column possibly and then render the
				##|  column using the column object.
				if @keyColumn and @tableName
					html += @renderCheckable(i)
				for col in @colList
					if @basePath != 0
						col.setBasePath @basePath + "/" + i.id
					str = col.Render(counter, i);
					html += str
				html += "</tr>";

			# counter++

		html += "</tbody></table>";

		@elTheTable = @elTableHolder.html(html);

		setTimeout () =>
			globalResizeScrollable();
			setupSimpleTooltips();
		, 100

		##|
		##|  This is a new render which means we need to re-establish any context menu
		@contextMenuCallSetup = 0
		@setupContextMenuHeader()
		@internalSetupMouseEvents()

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


