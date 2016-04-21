## -------------------------------------------------------------------------------------------------------------
## class to create input for the navbar
##
class NavInput

	## -------------------------------------------------------------------------------------------------------------
	## constructor to create new button
	##
	## @param [String] name of the input
	## @param [String] classes to add in button default is btn btn-primary
	## @param [Object] attrs additional attributes
	##
	constructor: (@name, @classes = "form-control", @attrs = {}) ->
		@classes = if @classes then @classes else "form-control"
		@attrs.name = @name
		if !@attrs.type
			@attrs.type = "text"


	## -------------------------------------------------------------------------------------------------------------
	## function to get the html of the current button
	##
	## @return [String]
	##
	getHtml: () ->
		$template = '''<input class="{{classes}}"
				{{#each attrs}}
					{{@key}}="{{this}}"
				{{/each}}

				>'''
		Handlebars.compile($template)(this)