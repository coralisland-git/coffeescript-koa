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

		@imgViewerBody = new WidgetTag "div", "container-fluid image-wrapper", "image-wrapper#{@gid}"
	
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
		if data.image? and @imgElement isnt data.image
			@imgElement = data.image
			isChanged = true
		if data.number? and @number isnt data.number
			@number = data.number
			isChanged = true
		if isChanged then @render()	
		true

	setImage: (@imgElement)=>

	setNumber: (@number)=>

	setSize: (w, h)=>
		@elementHolder.width w
		@elementHolder.height h
		if parseInt(w) < 400 or parseInt(h) < 300
			@numberBody.find(".numberCircle").addClass "numberCircle_Small"
			@numberBody.find(".numberCircle").removeClass "numberCircle"
		true
	drawImage: ()=>
		if @imgElement?.tagName is "IMG"
			@imgViewerBody.el.empty()
			@imgViewerBody.add "img", "image-rendered", "image_rendered#{@gid}", {"src": @imgElement.src}
	
		@elementHolder.append @imgViewerBody.el
		@imgViewerBody.show()
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
		true
