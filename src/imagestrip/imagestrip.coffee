class ImageViewer

	constructor: (holderElement, image, number) ->
		if !$(holderElement).length
			throw new Error "Element with selector#{holderElement} not found for ImageStrip"
		#if typeof holderElement is 'string'
		@elementHolder = $ holderElement

		@gid = GlobalValueManager.NextGlobalID()

		@imgElement = image

		@number = number

		@numberBody = 
			$ "<div />",
			class: "number_body"
			role: "numberBody"
			id: "number_body#{@gid}"

		@imgViewerBody = 
			$ "<div />",
			class: "container-fluid image-wrapper"
			id: "image-wrapper#{@gid}"

		true

	
	##|
	##|  click on one of the buttons
	handleClick : (e) =>
		the_gid = $(e.target).attr("id")
		for element in @imgElements
			if element.gid == the_gid
				if element.onClick? and typeof element.onClick == "function" and element.onClick(e)
					e.stopPropagation()
					e.preventDefault()

  		true

	setData: (data) =>
		if data.image?
			@imgElement = data.image
		if data.number
			@number = data.number
		true

	setImage: (@imgElement)=>

	setNumber: (@number)=>

	drawImage: ()=>
		if @imgElement?.tagName is "IMG"
			@imgViewerBody.empty()
			@imgViewerBody.append @imgElement
		@elementHolder.append @imgViewerBody
		true
	drawNumber: (number)=>
		if number >= 0
			@numberBody.empty()
			@numberBody.append($ "<span class='numberCircle'>#{parseInt(number)+1}</span>")
			@elementHolder.append @numberBody
		true

	render: () =>
		if @imgElement?
			@drawNumber(@number)
			@drawImage()
			console.log @number

		true
