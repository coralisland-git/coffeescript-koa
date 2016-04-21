## -------------------------------------------------------------------------------------------------------------
## class to create form for the navbar
##
class NavTabs

	## -------------------------------------------------------------------------------------------------------------
	## constructor to create new button
	##
	## @param [String] action to fill in the action
	## @param [String] align to align the form left|righta
	##
	constructor: (@align = 'left') ->
		# @property [Array] formElement to store the added form element
		@tabElements = []


	## -------------------------------------------------------------------------------------------------------------
	## function to get the html of the current button
	##
	## @return [String]
	##
	getHtml: () ->
		tabHtml = "";
		for element,key in @tabElements
			className = if key == 0 then 'active' else ''
			## activate first tab
			if key == 0
				$("#{element.link}").addClass('active')

			tabHtml += "<li class='#{className}'>
					<a href='#{element.link}' data-toggle='tab'>#{element.text}</a>
				</li>"

		$template = "<ul data-toggle='tabs' class='nav navbar-nav navbar-{{align}}'>
			#{tabHtml}
			</ul>"
		Handlebars.compile($template)(this)

	## -------------------------------------------------------------------------------------------------------------
	## function to add element to the navForm
	##
	## @param [Object] element a valid defined navbar object which must implement getHtml() method
	##
	addTabLink: (element) ->
		@tabElements.push element
