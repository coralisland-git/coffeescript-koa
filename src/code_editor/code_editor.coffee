##| CodeEditor Widget to edit the source code in the web app
##| example usage:
##| holder where editor will be render, mode which language the editor is used for
##| ce = new CodeEditor($('#test'), "mysql");

class CodeEditor

	###
    @property
    	private property to hold the editor instance for future reference and operations
	###
	_editor = null

	###
    @property
    	languageMode to decide which type of language is supported by the current editor instance
	###
	languageMode = "mysql"

	###
    @property _options [Object] to set the options to the editor
    ###
	_options = {}

	###
    @example
    	ce = new CodeEditor $("#editor"), "mysql"
    @param elementHolder [jQuery Element] the $() referenced element that will hold the editor
    @param languageMode [String] the language mode of the editor default is mysql
    @return this [CodeEditor] returns instance
	###
	constructor: (@elementHolder, @languageMode) ->
		if !@elementHolder.length
			throw new Error "The specified element #{@elementHolder.selector} not found"

		##| check if ace is loaded
		if typeof ace == "undefined"
			throw new Error "Ace editor is not loaded this component depends on ace, so ace editor must be loaded first"

		ace.require("ace/ext/language_tools");
		@_editor = ace.edit @elementHolder.attr('id');
		@_editor.session.setMode "ace/mode/mysql";
		this

	###
    set the different mode in the editor make sure it should find the necessary js file to load the specified mode
    @example
    	ce.setMode "php" it will automatically prepend the ace/mode/ in the string
    @param languageMode [String] the mode of language to select
    @return this [CodeEditor] returns current instance
	###
	setMode: (@languageMode) ->
		@_editor.session.setMode "ace/mode/#{@languageMode}"
		this

	###
    set the theme of the current editor instance
    @example
    	ce.setTheme "tomorrow_night_eighties" it will automatically prepend the ace/theme/ in the name
    ###
	setTheme: (themeName) ->
		@_editor.setTheme "ace/theme/#{themeName}"
		this


	###
    set the options to the ace editor, all the valid ace options can be passed
    @example
    	ce.setOptions
    		enableBasicAutocompletion: true
    @param options [Object] options to set in the editor
    @return this [CodeEditor] returns the current instance
	###
	setOptions: (@_options) ->
		console.log @_options
		@_editor.setOptions @_options
		this

	###
    to get the raw ace editor instance
    @example
    	aceInstance = ce.getInstance()
    @returns editor [ace]
	###
	getInstance: () ->
		@_editor

	###
    to get the current contents of the editor
    @example
    	code = ce.getContent()
    @return content [String] current content of the code editor
	###
	getContent: () ->
		return @_editor.session.getValue()

	###
    to set the new content in the editor
    @example
    	ce.setContent("this is new content")
    @param content [String] content to be set
    @return this [CodeEditor] current instance
	###
	setContent: (content) ->
		@_editor.session.setValue(content)
		this

	###
    to insert content at the current cursor position
    @example
    	ce.insert('new content')
    @param content [String] content to be inserted
    @return this [CodeEditor] current instance
	###
	insert: (content) ->
		@_editor.insert(content)
		this

	###
    to register the change handler with editor
    @example
    	ce.onChange (content,editor) ->
    			#content will be new updated content
    @param changeCallback [Function] function to be called on the change with content and editor as argument
    @return this [CodeEditor] current instance
	###
	onChange: (@changeCallback) ->
		@_editor.getSession().on 'change', (e) =>
			@changeCallback @getContent(), @_editor

