## -------------------------------------------------------------------------------------------------------------
## class to create form for the navbar
##
class NavForm

	## -------------------------------------------------------------------------------------------------------------
	## constructor to create new button
	##
	## @param [String] action to fill in the action
	## @param [String] align to align the form left|righta
	##
	constructor: (@action, @align = 'left') ->
		# @property [Array] formElement to store the added form element
		@formElements = []


	## -------------------------------------------------------------------------------------------------------------
	## function to get the html of the current button
	##
	## @return [String]
	##
	getHtml: () ->
		elementsHtml = "";
		for element in @formElements
			if ! @internalIsValidElement(element)
				console.log "element #{element.constructor.name} has not implemented .getHtml method";
			if element.constructor.name != 'NavButton'
				## if not button then wrap in form-group
				elementsHtml += "<div class='form-group'>#{element.getHtml()}</div>"
			else
				elementsHtml += element.getHtml()

		$template = "<form class='navbar-form navbar-{{align}}' method='post' action='#{@action}' role='search'>#{elementsHtml}</form>"
		Handlebars.compile($template)(this)

	## -------------------------------------------------------------------------------------------------------------
	## function to add element to the navForm
	##
	## @param [Object] element a valid defined navbar object which must implement getHtml() method
	##
	addElement: (element) ->
		if ! @internalIsValidElement(element)
			console.log "element #{element.constructor.name} has not implemented .getHtml method";
		@formElements.push(element)

	## -------------------------------------------------------------------------------------------------------------
	## internal function to check if incoming element is valid or not
	##
	## @param [Object] element a valid defined navbar object which must implement getHtml() method
	## @return [Boolean]
	##
	internalIsValidElement: (element) ->
		(element.__proto__.hasOwnProperty('getHtml') and typeof element.__proto__.getHtml == 'function')