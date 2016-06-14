## -------------------------------------------------------------------------------------------------------------
## class to create dynamicNavBar
##
class DynamicNav

	# @property [Boolean] staticTop weather to make it static-top
	staticTop = false

	# @property [Boolean] inverse weather to use nav-bar-inverse
	inverse = false

	## -------------------------------------------------------------------------------------------------------------
	## constructor to create dynamic nav
	##
	## @param [String|JQueryElement] holderElement the id of the element in which the nav bar should be rendered
	##
	constructor: (holderElement) ->
		if typeof holderElement == 'string' and !$(holderElement).length
			throw new Error "Element with selector #{holderElement} not found for nav"

		if typeof holderElement == 'string'
			holderElement = $ holderElement

		@gid = GlobalValueManager.NextGlobalID()

		@navElements = []

		@elementHolder = holderElement

		## create nav element
		@navBarHolder = $ "<nav />",
			class: "navbar navbar-default",
			role: "navigation"
			id: "nav_#{@gid}"

		## add container for the nav
		@navBarBody = $ "<div />",
			class: "container-fluid"

	## -------------------------------------------------------------------------------------------------------------
	## internal function to process the associated elements in the navbar
	##
	internalProcessElements: ->
		## prepare navbody by evaluating the elements
		for e in @navElements
			if e.__proto__.hasOwnProperty('getHtml') and typeof e.__proto__.getHtml == 'function'
				@navBarBody.append e.getHtml()
			else
				console.log "The element #{e.constructor.name} has not implemented getHtml() method"
		## prepare nav element
		@navBarHolder.html @navBarBody
		@navBarHolder.addClass "#{if @staticTop then 'navbar-static-top' else ''} #{if @inverse then 'navbar-inverse' else '' }"

	## -------------------------------------------------------------------------------------------------------------
	## render function to display the navbar that is built programatically
	##
	render: =>
		@internalProcessElements()
		@elementHolder.append @navBarHolder

		## bind the NavDropDown events once all elements are rendered
		dropdownElements = @navElements.filter (e) -> e.constructor.name == 'NavDropDown'
		if dropdownElements.length
			for element,key in dropdownElements
				for item,key in element.dropdownItems
					@elementHolder.find "#dd#{element.gid}_#{key}"
						.on "click", item.callback

		for element in @navElements
			if element.gid?
				@elementHolder.find "##{element.gid}"
					.on "click", (e)=>
						@handleClick(e)

	##|
	##|  click on one of the buttons
	handleClick : (e) =>
		the_gid = $(e.target).attr("id")
		for element in @navElements
			if element.gid == the_gid
				if element.onClick? and typeof element.onClick == "function" and element.onClick(e)
					e.stopPropagation()
					e.preventDefault()

  		true

	## -------------------------------------------------------------------------------------------------------------
	## function to add element to the navbar
	##
	## @param [Object] element a valid defined navbar object which must implement getHtml() method
	##
	addElement: (element) ->
		if !(element.__proto__.hasOwnProperty("getHtml") and typeof element.__proto__.getHtml == 'function')
			console.log "element #{element.constructor.name} has not implemented .getHtml method";
		@navElements.push(element)
		this
