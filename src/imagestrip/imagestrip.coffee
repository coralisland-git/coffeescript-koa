class ImageViewer

	# boundary values that are used to determine if image number should be smaller or not
	boundaryValue_Width: 400
	boundaryValue_Height: 300

	constructor: (holderElement, image, number) ->
		if !$(holderElement).length
			throw new Error "Element with selector#{holderElement} not found for ImageStrip"
		
		@elementHolder = $ holderElement

		@gid = GlobalValueManager.NextGlobalID()
		# @property [jQuery] jQuery element representing <img>
		@imgElement = image
		# @property [Int] number of image shown at the top right corner of image
		@number = number
		# @property [jQuery] jQuery element showing number of image 
		@numberBody = 
			$ "<div />",
			class: "number_body"
			id: "number_body#{@gid}"
		# @property [jQuery] jQuery element showing image viewer
		@imgViewerBody = new WidgetTag "div", "container-fluid image-wrapper", "image-wrapper#{@gid}"
	
		true

  	## ------------------------------------------------------------------------------------------
  	## function to set image source and its number
  	## @param [Object] data: includes image source and number
  	## @return [Boolean] isChanged: true if data is new
	setData: (data) =>
		isChanged = false
		if data.image? and @imgElement isnt data.image
			@imgElement = data.image
			isChanged = true
		if data.number? and @number isnt data.number
			@number = data.number
			isChanged = true
		if isChanged then @render()	
		return isChanged
	
	## function to set image source
	setImage: (@imgElement)=>
	
	## function to set image number
	setNumber: (@number)=>
	
	## ------------------------------------------------------------------------------------------
	## function to set size of image view
	## @param [int] w: width to be set
	## @param [int] h: height to be set
	## @return [Boolean]
	## 
	setSize: (w, h)=>
		@elementHolder.width w
		@elementHolder.height h
		if parseInt(w) < @boundaryValue_Width or parseInt(h) < @boundaryValue_Height
			@numberBody.find(".numberCircle").addClass "numberCircle_Small"
			@numberBody.find(".numberCircle").removeClass "numberCircle"
		true
	
	## ------------------------------------------------------------------------------------------
	## function to draw image
	##
	drawImage: ()=>
		if @imgElement?.tagName is "IMG"
			@imgViewerBody.el.empty()
			@imgViewerBody.add "img", "image-rendered", "image_rendered#{@gid}", {
				"src": @imgElement.src
			}
	
		@elementHolder.append @imgViewerBody.el
		@imgViewerBody.show()
		true
	
	## ------------------------------------------------------------------------------------------
	## function to draw number of image
	##
	drawNumber: (number)=>
		if number >= 0
			@numberBody.empty()
			@numberBody.append($ "<span class='numberCircle'>#{parseInt(number)+1}</span>")
			@elementHolder.append @numberBody
		true
	
	## ------------------------------------------------------------------------------------------
	## function to render entire imageviewer, just draws image and number
	##	
	render: () =>
		if @imgElement?
			@drawNumber(@number)
			@drawImage()
		true
