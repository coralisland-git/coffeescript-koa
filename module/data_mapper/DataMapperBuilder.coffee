## -------------------------------------------------------------------------------------------------------------
## class DataMapperBuilder to build datamap and perform common data related operation
##
class DataMapperBuilder

	## -------------------------------------------------------------------------------------------------------------
    ## deserialize the passed json string into javascript object
	##
	## @param [String] text string to parse must be valid json string
    ## @return [Object] parsed javascript object from json string
    ##
	deserialize: (txt) =>

		try
			@mapData = JSON.parse txt
		catch e
			##|  ignore parse errors
			console.log "DataMapperBuilder, deserialize: ", e

		@redrawDataTypes()

		setTimeout ()=>
			# @addTransformRule('GF20030226223929852543000000','transform','asdf','asdfadsf');
			console.log "test"
			# @serialize()
		, 1500

	## -------------------------------------------------------------------------------------------------------------
    ## serialize the currently mapped data object and create string from that
	##
	## @return [String] converted json string
    ##
	serialize: () =>
		text = JSON.stringify(@mapData)
		console.log "TEXT=", text

	## -------------------------------------------------------------------------------------------------------------
    ## Add a transformation rule to a given field
	## if that rule already exists, update it
	##
	## @param [String] clickName
	## @param [String] ruleType
	## @param [String] pattern
	## @param [Object] dest
    ## @return [Object] parsed javascript object from json string
    ##
	addTransformRule: (clickName, ruleType, pattern, dest) =>

		console.log "addTransformRule('#{clickName}','#{ruleType}','#{pattern}','#{dest}');"

		##|
		##|  Add the new rule under the "transform" array
		##|

		if !@mapData[clickName]? then return
		if !@mapData[clickName].transform?
			@mapData[clickName].transform = []

		for t in @mapData[clickName].transform
			if t.type == ruleType and t.pattern == pattern
				t.dest = dest
				@redrawDataTypes()
				return true

		##|
		##|  Create a new rule
		@mapData[clickName].transform.push
			type    : ruleType
			pattern : pattern
			dest    : dest

		@redrawDataTypes()
		true


	## -------------------------------------------------------------------------------------------------------------
    ## click the + sign to add a rule to an item
	##
	## @param [Event] object of jquery Event
    ## @return [Boolean]
    ##
	onClickMapPlus: (e) =>

		e.stopPropagation()
		e.preventDefault()

		clickName = $(e.currentTarget).attr("box_name")

		console.log "CURRENT:", @mapData[clickName]

		for idx, dataType of @KnownFields.colList
			if dataType.name == @mapData[clickName].mapName
				console.log "KNOWN  :", dataType

		m = new ModalDialog
			showOnCreate: false
			content:      "Add a custom processing rule, mapping to field: "
			position:     "top"
			title:        "Custom Rule"
			ok:           "Save"

		m.getForm().addTextInput "pattern",     "Target Pattern"
		m.getForm().addTextInput "destination", "Map To"

		m.getForm().onSubmit = (form) =>
			##|
			##|  Add a new type of mapping rule
			console.log "Form=", form
			@addTransformRule clickName, "transform", form.pattern, form.destination
			true

		m.show()

	## -------------------------------------------------------------------------------------------------------------
    ## onclickmap to bind the click event
	##
	## @param [Event] object of jQuery Event
    ##
	onClickMap: (e) =>

		e.stopPropagation()
		e.preventDefault()

		clickName = $(e.currentTarget).attr("box_name")

		##|
		##|  Grab a reference to the row that was selected
		elBox = @SourceFields[clickName]

		##|
		##|  Create the popup menu
		pop = new PopupMenu "Map '#{clickName}'", e
		pop.resize(400)

		pop.addItem "Edit Target", (e, info) =>
			@onSelectEdit clickName

		for idx, dataType of @KnownFields.colList

			if dataType.isSelected? and dataType.isSelected

				pop.addItem "Copy to " + dataType.name, (e, info) =>
					@onSelectMap info, clickName, "copy"
				, idx

				pop.addItem "Append to " + dataType.name, (e, info) =>
					@onSelectMap info, clickName, "append"
				, idx

	## -------------------------------------------------------------------------------------------------------------
    ## when single item is selected from popup
	##
	## @param [String] clickName item that is clicked
    ## @return [Boolean]
    ##
	onSelectEdit: (clickName) =>

		m = new ModalDialog
			showOnCreate: false
			content:      "Type a field name or custom field"
			position:     "top"
			title:        "Field Mapping"
			ok:           "Save"

		fieldNames = []
		for idx, dataType of @KnownFields.colList
			fieldNames.push dataType.name

		m.getForm().addTextInput "dest", "Target Field"
		.makeTypeahead fieldNames

		m.getForm().onSubmit = (form) =>
			console.log "Submitted form, test value=", form.dest
			for idx, dataType of @KnownFields.colList
				if form.dest == dataType.name
					dataType.mapdata.mapType = "copy"
					dataType.mapdata.mapSource = clickName
					@mapData[clickName] =
						mapType: "copy"
						mapSource: clickName
						mapDest: dataType.source
						mapName: dataType.name
					@redrawDataTypes()
					m.hide()
					return

			@mapData[clickName] =
				mapType: "formula"
				mapSource: clickName
				mapDest: form.dest
				mapName: null
			@redrawDataTypes()

			m.hide()

		m.show()

	## -------------------------------------------------------------------------------------------------------------
    ## onSelectMap
	##
	## @param [String] idx columns identifier
	## @param [String] clickName the name of the click
	## @param [String] action name of the action to be taken
    ##
	onSelectMap: (idx, clickName, action) =>

		delete @KnownFields.colList[idx].isSelected
		@KnownFields.colList[idx].el.removeClass "selected"

		@KnownFields.colList[idx].mapdata.mapType = action
		@KnownFields.colList[idx].mapdata.mapSource = clickName

		@mapData[clickName] =
			mapType: action
			mapSource: clickName
			mapDest: @KnownFields.colList[idx].source
			mapName: @KnownFields.colList[idx].name

		@redrawDataTypes()
		console.log "MAP=", @mapData


	## -------------------------------------------------------------------------------------------------------------
    ## when someone clicks on one of the known map sources on the
	## right, mark it as selected and remove the selection mark from
	## all the other possible sources
	##
	## @param [Event] jQuery Event object
    ##
	onSelectDatatype: (e) =>
		e.stopPropagation()
		e.preventDefault()

		idx = $(e.currentTarget).attr("idx")

		if @KnownFields.colList[idx].isSelected?
			console.log "Remove ", idx
			@KnownFields.colList[idx].el.removeClass "selected"
			delete @KnownFields.colList[idx].isSelected
		else
			console.log "Set ", idx
			@KnownFields.colList[idx].el.addClass "selected"
			@KnownFields.colList[idx].isSelected = true

		# @removeAllSelected(idx)

	## -------------------------------------------------------------------------------------------------------------
    ## Deselect any selected indexes on the right
	##
	## @param [Integer] exceptedIndex index to Deselect
    ##
	removeAllSelected: (exceptedIndex) =>

		##|
		##|  Remove other selected
		for idx, dataType of @KnownFields.colList
			if idx != exceptedIndex and dataType.isSelected? and dataType.isSelected
				dataType.el.removeClass "selected"
				delete dataType.isSelected

	## -------------------------------------------------------------------------------------------------------------
    ## function to redrawTransformRules
	##
	## @param [String] name identifier of the table
	## @param [String] field name of the column to consider
    ##
	redrawTransformRules: (name, field) =>

		if !@mapData[name].transform? then return false
		for t in @mapData[name].transform

			if !field.elTransformTable?
				td = $ "<td colspan='2' />"
				field.elTransformTable = $ "<table class='transformRuleTable' />"
				td.append field.elTransformTable
				field.elTransform.append td
				field.elTransfromElements = {}

			if !field.elTransfromElements[t.name]?

				row = $ @templateRuleLine(t)
				field.elTransfromElements[t.name] = field.elTransformTable.append row

	## -------------------------------------------------------------------------------------------------------------
    ## function to redraw data types
	## @return [Boolean]
	##
	redrawDataTypes: () =>

		##
		for idx, dataType of @KnownFields.col

			found = false
			# dataType = @KnownFields.col[dataTypeName]
			for i, mapdata of @mapData

				if mapdata.mapName == dataType.name

					if mapdata.mapType == "copy"
						dataType.el.find("i").addClass "fa-tag"
						dataType.el.addClass "assigned"
						found = true
					else if mapdata.mapType == "append"
						dataType.el.find("i").addClass "fa-copy"
						dataType.el.addClass "assigned"
						found = true

			if not found
				dataType.el.find("i").removeClass "fa-tag"
				dataType.el.find("i").removeClass "fa-copy"
				dataType.el.removeClass "assigned"


		for name, field of @SourceFields
			found = true
			if @mapData[name]? and @mapData[name].mapType == "copy"
				field.mapBox.html "<i class='fa fa-fw fa-tag'/> Copy to " + @mapData[name].mapDest
				field.el.children().addClass "assigned"
				@redrawTransformRules name, field
			else if @mapData[name]? and @mapData[name].mapType == "append"
				field.mapBox.html "<i class='fa fa-fw fa-copy'/> Append to " + @mapData[name].mapDest
				field.el.children().addClass "assigned"
				@redrawTransformRules name, field
			else if @mapData[name]? and @mapData[name].mapType == "formula"
				field.mapBox.html "<i class='fa fa-fw fa-arrow-right'/> Custom to " + @mapData[name].mapDest
				field.el.children().addClass "assigned"
				@redrawTransformRules name, field
			else
				found = false
				field.mapBox.html "<i class='fa fa-fw'/> None"
				field.el.children().removeClass "assigned"

			if found
				field.mapBoxPlus.show()
			else
				field.mapBoxPlus.hide()

		@serialize()
		true

	## -------------------------------------------------------------------------------------------------------------
    ## create the data in each field that holds the map configuration
	##
	setupKnownFields: () =>

		for idx, dataType of @KnownFields.colList
			dataType.mapdata =
				mapType : "none"


	## -------------------------------------------------------------------------------------------------------------
    ## constructor
	##
	## @param [Object] sourceObj
	## @param [Array] knownFields
	## @param [JQueryElement] holder element to render
    ##
	constructor: (sourceObj, knownFields, holder) ->

		##
		try

			@mapData      = {}
			@SourceFields = {}
			@KnownFields  = knownFields

			@elMain = $(holder).append "<table class='dataMapperMain' />"
			@elMain.css
				width    : "100%"

			codes = (k for k of sourceObj)
			correctOrder = codes.sort (a, b) ->
				if sourceObj[a] and not sourceObj[b] then return -1
				if sourceObj[b] and not sourceObj[a] then return 1
				if a.toUpperCase() < b.toUpperCase() then return -1
				if a.toUpperCase() > b.toUpperCase() then return 1
				return 0

			@setupKnownFields();

			@templateRuleLine = Handlebars.compile '''
				<tr>
				<td class='ruleType'> {{type}} </td>
				<td class='rulePattern'> {{pattern}} </td>
				<td class='ruleDest'> {{dest}} </td>
				<td class='ruleMinus'> <i class='fa fa-minus' /> </td>
				</tr>
			'''

			yPos = 0
			for name in correctOrder
				value = sourceObj[name]

				label = $ "<label />",
					html: name

				sampleData = $ "<div />",
					html: value
					class: "data"

				elBox = {}
				elBox.name = name
				elBox.value = value
				elBox.el = $ "<tr />",
					id       : "builder_#{name}"
					class	 : "mapColumn"

				elBox.mapBox = $ "<td />",
					class    : "mapBox"
					html     : "None"
					box_name : name

				elBox.mapBoxPlus = $ "<td />",
					class    : "mapBoxPlus"
					html     : "<i class='fa fa-fw fa-plus' />"
					box_name : name

				elBox.mapBox.on 'click', @onClickMap

				elBox.mapBoxPlus.on 'click', @onClickMapPlus

				elBox.el.append label
				elBox.el.append sampleData
				elBox.el.append elBox.mapBox
				elBox.el.append elBox.mapBoxPlus

				elBox.el.css
					padding         : "4px"
					backgroundColor : "#eeeeee"

				@SourceFields[name] = elBox

				##|
				##|  Transform rules
				elBox.elTransform = $ "<tr />",
					id: "tr_#{name}"
					class: "transformRules"

				@elMain.append elBox.el
				@elMain.append elBox.elTransform
				yPos += 44

			##|
			##|  List of known fields on the right

			elKnown = $ "<div />",
				id: "knownColumns"
				class: "knownColumns"

			elKnown.append $ "<div />",
				class: "knownTitle"
				html: "Mappable Columns"

			for idx, dataTypeName of @KnownFields.colList

				dataType = @KnownFields.col[dataTypeName]
				el = $ "<div />",
					class:   "knownItem"
					popname: dataType.source
					idx:     idx
					html:    "<i class='fa fa-fw' /> " + dataType.name

				el.on "click", @onSelectDatatype

				dataType.el = el
				elKnown.append el

			@elMain.append elKnown
			@redrawDataTypes();

			##|
			##|  Fix the width
			w = @elMain.width()
			@elMain.css "width", w-240

		catch e
			console.log "Exception in DataMapperBuilder: ", e, e.stack
