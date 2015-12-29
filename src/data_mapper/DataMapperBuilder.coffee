class DataMapperBuilder

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

		for idx, dataType of @KnownFields.colList
			if dataType.isSelected? and dataType.isSelected

				pop.addItem "Copy to " + dataType.name, (e, info) =>
					@onSelectMap info, clickName, "copy"
				, idx

				pop.addItem "Append to " + dataType.name, (e, info) =>
					@onSelectMap info, clickName, "append"
				, idx

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
			if dataType.mapdata.mapType == "copy"
				dataType.el.find("i").addClass "fa-tag"
				dataType.el.addClass "assigned"
			else if dataType.mapdata.mapType == "append"
				dataType.el.find("i").addClass "fa-copy"
				dataType.el.addClass "assigned"
			else
				dataType.el.find("i").removeClass "fa-tag"
				dataType.el.removeClass "assigned"

		for name, field of @SourceFields
			if @mapData[name]? and @mapData[name].mapType == "copy"
				field.mapBox.html "<i class='fa fa-fw fa-tag'/> Copy to " + @mapData[name].mapDest
				field.el.children().addClass "assigned"
			else if @mapData[name]? and @mapData[name].mapType == "append"
				field.mapBox.html "<i class='fa fa-fw fa-copy'/> Append to " + @mapData[name].mapDest
				field.el.children().addClass "assigned"
			else
				field.mapBox.html "<i class='fa fa-fw'/> None"
				field.el.children().removeClass "assigned"

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

			console.log "Holder=", holder
			console.log @elMain

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

				elBox.mapBox.on 'click', @onClickMap

				elBox.el.append label
				elBox.el.append sampleData
				elBox.el.append elBox.mapBox

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