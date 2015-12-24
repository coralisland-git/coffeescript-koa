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
		pop = new PopupMenu "Map Destination", e

		for idx, dataType of @KnownFields.colList
			pop.addItem dataType.name + dataType.editable, (e, info) =>
				console.log "Clicked ", info
				true
			, dataType

	constructor: (sourceObj, knownFields, holder) ->

		##
		try

			@elMain = $(holder)
			@elMain.css
				height   : "80%"
				position : "absolute"
				width    : "800px"

			console.log "Holder=", holder
			console.log @elMain

			codes = (k for k of sourceObj)
			correctOrder = codes.sort (a, b) ->
				if sourceObj[a] and not sourceObj[b] then return -1
				if sourceObj[b] and not sourceObj[a] then return 1
				if a.toUpperCase() < b.toUpperCase() then return -1
				if a.toUpperCase() > b.toUpperCase() then return 1
				return 0

			@SourceFields = {}
			@KnownFields  = knownFields

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

			# @elMain.css "height", yPos + 10

		catch e
			console.log "Exception in DataMapperBuilder: ", e, e.stack