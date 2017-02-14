class WidgetSplittable

	validProperties: ["sizes", "minSize", "direction", "gutterSize"
					"snapOffset", "cursor", "elementStyle", "gutterStyle"
					"onDrag", "onDragStart", "onDragEnd"]
	validDirections: ["horizontal", "vertical"]

	constructor: (@elementHolder) ->
		@splitData = {}
		@element1 = new WidgetTag "div", "split", "split_1"
		@element1.appendTo @elementHolder

		@element2 = new WidgetTag "div", "split", "split_2"
		@element2.appendTo @elementHolder
		true

	setData: (data) =>
		if !@checkValidData data then return false
		for prop in @validProperties
			@splitData[prop] = data[prop]
		return true
	checkValidData: (data) =>
		if !window.Split 
			console.log "Error: Plugin Split not loaded"
			
		if @validDirections.indexOf(data.direction) is -1
			return false 

		true

	render: (data) =>
		if !@setData(data) then return false
		direction = @splitData.direction
		@element1.addClass "split-#{direction}"
		@element2.addClass "split-#{direction}"
		Split ["##{@element1.id}", "##{@element2.id}"], @splitData
		true

	getFirstChild: () =>
		return @element1

	getSecondChild: () =>
		return @element2 

