## -------------------------------------------------------------------------------------------------------------
## class TableEditor Widget to render table column editor
##
## @example
##		te = new TableEditor($("#test"), "zipcode")
##
class TableEditor

	# @property [Boolean] allowButtons weather buttons should appear
	allowButtons: true

	# @property [Function|Boolean] onCreate callback to call on creation of table row
	onCreate: false

	# @property [Boolean] render weather to render automatically or call externally
	render: true

	## -------------------------------------------------------------------------------------------------------------
	## constructor to create new tableEditor
	##
	## @param [JQueryElement] tableHolder jquery element in which the table will be rendered
	## @param [String] editedTableKey the key column which will be used to track rows
	## @param [Boolean] render render it automatically default true
	##
	constructor: (@tableHolder, @editedTableKey, @render = true) ->

		##| add div for table inside @tableHolder
		if !@tableHolder.length and @render
			console.error "The element with selector #{@tableHolder.selector} not found"
		dm = DataMap.getDataMap()

		if !@editedTableKey or !dm.types[@editedTableKey]
			throw new Error "invalid table key #{@editedTableKey} is supplied"

		@rowsList = dm.types[@editedTableKey].col
		@gid = GlobalValueManager.NextGlobalID()

		tableElement = $ "<div />"
		.attr('id', "_editor#{@gid}")
		.attr('data-id', "_editor#{@gid}")

		@tableHolder.append tableElement

		@editorTable = new TableView tableElement
		@internalSetDataTypes()
		@editorTable.addTable "_editor_#{@editedTableKey}"
		@editorTable.showFilters = false
		if @render
			@editorTable.render()

		if @allowButtons
			@internalCreateButtons()

	## -------------------------------------------------------------------------------------------------------------
	## function to get the created table instance
	##
	## @return [TableView] editorTable
	##
	getTableInstance: ->
		return @editorTable

	## -------------------------------------------------------------------------------------------------------------
	## clears the html of the table used to remove the table
	##
	clear: ->
		@tableHolder.html ""

	## -------------------------------------------------------------------------------------------------------------
	## internal function to sets the data type in the the datamap for the editor table
	##
	internalSetDataTypes: () ->
		if DataMap.getDataMap().types["_editor_#{@editedTableKey}"]
			return true
		##| These data type will be same for all the table editor
		DataMap.setDataTypes "_editor_#{@editedTableKey}", [
			{
				name: "Name"
				source: "name"
				visible: true,
				type: "text"
				editable: true
				required: true
				width: 120
			}
			{
				name: "Source"
				source: "source"
				visible: true,
				type: "text"
				editable: true
				width: 120
			}
			{
				name: "Visible"
				source: "visible"
				visible: true,
				type: "boolean"
				editable: true
				width: 120
			}
			{
				name: "Hideable"
				source: "hideable"
				visible: true,
				type: "boolean"
				editable: true
				width: 120
			}
			{
				name: "Type"
				source: "type"
				visible: true,
				type: "enum"
				editable: true
				required: true
				width: 120,
				element: "select",
				options: Object.keys globalDataFormatter.formats
			}
			{
				name: "Width"
				source: "width"
				visible: true,
				type: "text"
				editable: true
				width: 120
			}
			{
				name: "Tooltip"
				source: "tooltip"
				visible: true,
				type: "text"
				editable: true
				width: 120
			}
			{
				name: "Sortable"
				source: "sortable"
				visible: true,
				type: "boolean"
				editable: true
				width: 120
			}
			{
				name: "Required"
				source: "required"
				visible: true,
				type: "boolean"
				editable: true
				width: 120
			}
			{
				name: "Render"
				source: "render"
				visible: true,
				type: "sourcecode"
				editable: true
				width: 120
			}
		]

		##| add row data to dataMap about current column configurations

		for key,row of @rowsList
			preparedRow = @intenalFilterRowValues(row)
			DataMap.addData "_editor_#{@editedTableKey}", row.source, preparedRow

	## -------------------------------------------------------------------------------------------------------------
	## internal function to select only properties from the row
	##
	## @param [Object] row the object of row having dataType informations
	##
	intenalFilterRowValues: (row) ->
		preparedRow = {}
		rowElements = ["name", "source", "visible", "hideable", "type", "width", "tooltip", "sortable", "render"]
		for element in rowElements
			preparedRow[element] = row[element]
		preparedRow

	## -------------------------------------------------------------------------------------------------------------
	## internal function to create buttons for the editor table
	##
	internalCreateButtons: ->
		button1 = $('<button />')
		.addClass 'btn btn-success'
		.text "Create New"
		.attr 'id', "_editor_#{@editedTableKey}_create"
		button2 = $('<button />')
		.addClass 'btn btn-primary'
		.text "Save"
		.attr 'id', "_editor_#{@editedTableKey}_save"
		.css 'margin-left', '10px'

		@tableHolder.prepend button2
		.prepend button1

		@internalSetButtonEvents()

	## -------------------------------------------------------------------------------------------------------------
	## internal function to sets event for the created button
	##
	internalSetButtonEvents: ->
		table = @editorTable
		$("#_editor_#{@editedTableKey}_create").on "click", =>
			p = new PopupForm("_editor_#{@editedTableKey}", "source", null, null, {
				visible: 1,
				hideable: 1,
				required: 0,
				sortable: 1,
				type: "text"
			})
			p.onCreateNew = (tableName, data) =>
				##| update data map data types if new inserted and add in rowList
				DataMap.setDataTypes tableName, [data]
				DataMap.setDataTypes @editedTableKey, [data]
				@rowsList[data.source] = data
				##| apply filter or sorting to update the newly create row
				setTimeout () ->
					table.applyFilters()
				, 1
				if @onCreate and typeof @onCreate is 'function'
					@onCreate(data)
				else
					true

		$("#_editor_#{@editedTableKey}_save").on "click", =>
			currentConfig = []
			for key, row of @rowsList
				currentConfig.push @intenalFilterRowValues(row)
			new ModalDialog
				title: "Table Configurations"
				content: "<textarea id='_pretty_print#{@editedTableKey}' cols='50' rows='50' class='form-control'>#{JSON.stringify(currentConfig, undefined, 4);}</textarea>"
