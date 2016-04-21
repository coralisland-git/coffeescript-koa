## -------------------------------------------------------------------------------------------------------------
## class to create button for the navbar
##
class NavButton

	## -------------------------------------------------------------------------------------------------------------
	## constructor to create new button
	##
	## @param [String] value to display
	## @param [String] classes to add in button default is btn btn-primary
	## @param [Object] attrs additional attributes
	##
	constructor: (@value, @classes = "btn btn-primary", @attrs = {}) ->
		@classes = if @classes then @classes else "btn btn-primary"
		if !@attrs.type
			@attrs.type = "submit"

	## -------------------------------------------------------------------------------------------------------------
	## function to get the html of the current button
	##
	## @return [String]
	##
	getHtml: () ->
		$template = '''<button class="{{classes}}"
				{{#each attrs}}
					{{@key}}="{{this}}"
				{{/each}}
				>{{value}}</button>'''
		Handlebars.compile($template)(this)