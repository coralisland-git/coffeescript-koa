## -------------------------------------------------------------------------------------------------------------
## class to create dropdown for the navbar
##
class NavDropDown

	## -------------------------------------------------------------------------------------------------------------
	## constructor to create new button
	##
	## @param [String] action to fill in the action
	## @param [String] align to align the form left|righta
	##
	constructor: (@title,@align = 'left') ->
		# @property [Array] formElement to store the added form element
		@dropdownItems = []


	## -------------------------------------------------------------------------------------------------------------
	## function to get the html of the current button
	##
	## @return [String]
	##
	getHtml: () ->
		itemsHtml = "";
		for element in @dropdownItems
			if element.type isnt 'divider'
				itemsHtml += "<li><a href='#{element.link}'>#{element.text}</a></li>"
			else
				itemsHtml += "<li role='separator' class='divider'></li>"

		$template = "<ul class='nav navbar-nav navbar-{{align}}'>
				<li class='dropdown'>
				<a href='#' class='dropdown-toggle' data-toggle='dropdown' role='button' aria-haspopup='true' aria-expanded='false'>#{@title} <span class='caret'></span></a>
				<ul class='dropdown-menu'>#{itemsHtml}</ul>
			</ul>"
		Handlebars.compile($template)(this)

	## -------------------------------------------------------------------------------------------------------------
	## function to add element to the navForm
	##
	## @example
	##		dd.addItem({"Visit Link": "http://sample.com"}) where key is display value and value is the link set in href
	## @param [Object] element a valid defined navbar object which must implement getHtml() method
	##
	addItem: (item) ->
		@dropdownItems.push(item)
