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

	constructor: (@value, @classes = "toolbar-btn navbar-btn", @attrs = {}) ->
		@classes = if @classes then @classes else "toolbar-btn navbar-btn"
		if !@attrs.type
			@attrs.type = "submit"

		@gid = "b" + GlobalValueManager.NextGlobalID()

	## -------------------------------------------------------------------------------------------------------------
	## function to get the html of the current button
	##
	## @return [String]
	##
	getHtml: () ->
		$template = '''<button class="{{classes}}" id="{{gid}}"
				{{#each attrs}}
					{{@key}}="{{this}}"
				{{/each}}
				>{{{value}}}</button>'''
		Handlebars.compile($template)(this)

	onClick: ()=>
		console.log "Click this button: ", this
		true