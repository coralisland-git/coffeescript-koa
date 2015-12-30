class DataMapperBuilder

	deserialize: (txt) =>

		@mapData = JSON.parse txt
		@redrawDataTypes()

	serialize: () =>
		text = JSON.stringify(@mapData)
		console.log "TEXT=", text

	##|
	##|  Click the + sign to add a rule to an item
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

		m.getForm().addTextInput "pattern", "Target Pattern"
		m.getForm().addTextInput "Destination", "Map To"

		m.getForm().onSubmit = (form) =>
			console.log "Form=", form

		m.show()

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

	##|
	##|  When someone clicks on one of the known map sources on the
	##|  right, mark it as selected and remove the selection mark from
	##|  all the other possible sources.
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

	##|
	##|  Deselect any selected indexs on the right
	removeAllSelected: (exceptedIndex) =>

		##|
		##|  Remove other selected
		for idx, dataType of @KnownFields.colList
			if idx != exceptedIndex and dataType.isSelected? and dataType.isSelected
				dataType.el.removeClass "selected"
				delete dataType.isSelected

	redrawDataTypes: () =>

		##
		for idx, dataType of @KnownFields.colList

			found = false
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
			else if @mapData[name]? and @mapData[name].mapType == "append"
				field.mapBox.html "<i class='fa fa-fw fa-copy'/> Append to " + @mapData[name].mapDest
				field.el.children().addClass "assigned"
			else if @mapData[name]? and @mapData[name].mapType == "formula"
				field.mapBox.html "<i class='fa fa-fw fa-arrow-right'/> Custom to " + @mapData[name].mapDest
				field.el.children().addClass "assigned"
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

	##|
	##|  Create the data in each field that holds the map configuration
	setupKnownFields: () =>

		for idx, dataType of @KnownFields.colList
			dataType.mapdata =
				mapType : "none"


	constructor: (sourceObj, knownFields, holder) ->

		##
		try

			@mapData      = {}
			@SourceFields = {}
			@KnownFields  = knownFields

			@elMain = $(holder)
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
				elBox.el = $ "<div />",
					id       : "builder_#{name}"
					class	 : "mapColumn"

				elBox.mapBox = $ "<div />",
					class:    "mapBox"
					html:     "None"
					box_name: name

				elBox.mapBoxPlus = $ "<div />",
					class:    "mapBoxPlus"
					html:     "<i class='fa fa-fw fa-plus' />"
					box_name: name

				elBox.mapBox.on 'click', @onClickMap

				elBox.mapBoxPlus.on 'click', @onClickMapPlus

				elBox.el.append label
				elBox.el.append sampleData
				elBox.el.append elBox.mapBox
				elBox.el.append elBox.mapBoxPlus

				elBox.el.css
					padding         : "4px"
					# position        : 'absolute'
					# top             : yPos + "px"
					# left            : 10 + "px"
					backgroundColor : "#eeeeee"

				@SourceFields[name] = elBox

				@elMain.append elBox.el
				yPos += 44

			##|
			##|  List of known fields on the right

			elKnown = $ "<div />",
				id: "knownColumns"
				class: "knownColumns"

			elKnown.append $ "<div />",
				class: "knownTitle"
				html: "Mappable Columns"

			for idx, dataType of @KnownFields.colList

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

			# @elMain.css "height", yPos + 10

		catch e
			console.log "Exception in DataMapperBuilder: ", e, e.stack