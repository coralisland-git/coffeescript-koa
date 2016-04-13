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
    @property _histories [Array] to access the recent usage of the code
    ###
	_histories = []

	###
    @example
    	ce = new CodeEditor $("#editor"), "mysql"
    @param elementHolder [jQuery Element] the $() referenced element that will hold the editor
    @param languageMode [String] the language mode of the editor default is mysql
    @return this [CodeEditor] returns instance
	###
	constructor: (@elementHolder, @languageMode = "mysql") ->
		if !@elementHolder.length
			throw new Error "The specified element #{@elementHolder.selector} not found"

		##| check if ace is loaded
		if typeof ace == "undefined"
			throw new Error "Ace editor is not loaded this component depends on ace, so ace editor must be loaded first"

		ace.require("ace/ext/language_tools");
		@_editor = ace.edit @elementHolder.attr('id');
		@setMode @languageMode;
		@gid = GlobalValueManager.NextGlobalID()
		@_histories = []
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

	###
    to add the code into most recent history
    @example
    	ce.addToHistory "select * from users"
    @param code [String] code to insert into recent history
	###
	addToHistory: (code) ->
		if @_histories.indexOf(code) is -1
			@_histories.unshift code
		else
			_index = @_histories.indexOf code
			@_moveHistoryItem(_index,0)
		@saveHistory()

	###
    to save history to the local storage
    @example
    	ce.saveHistory()
	###
	saveHistory: () ->
		##| to save only 100 records
		_histories = JSON.stringify @_histories.splice 0,100
		localStorage.setItem "_histories_#{@gid}",_histories

	###
    to get save histories from the localstorage
    @example
    	ce.getHistories()
    ###
	getHistories: () ->
		_histories = localStorage.getItem "_histories_#{@gid}"
		if _histories
			return JSON.parse _histories
		false

	###
    internal function to move order of the array item from one index to another
    @param oldIndex [Integer] current index from where to pick element
    @param newIndex [Integer] desired index where element should be moved
	###
	_moveHistoryItem: (oldIndex,newIndex) ->
		if newIndex >= @_histories.length
			_temp = newIndex - @_histories.length;
			while ((_temp--) + 1)
				@_histories.push undefined
		@_histories.splice(newIndex, 0, @_histories.splice(oldIndex, 1)[0]);
		return this;

	###
    to render the recent histories in select
    @example
    	ce.renderHistories $(".select"), (value,element) ->
    		ce.setContent value
    @param holder [JqueryElement] reference to jquery element where select should be rendered
    	default it will prepend to code editor holder
    @param changedCallback [Function] function to call when select box value is changed
	###
	renderHistories: (holder = null, changedCallback = null) ->
		if !holder
			throw new Error "please provide element to render select box"
		select = $ "<select />"
		select.attr 'id',"#{@gid}_histories"
			.addClass "form-control"
		_options = @_getOptionsForSelect()
		select.append _options
		select.on "change", () ->
			if changedCallback
				changedCallback select.val(), select
		holder.html select

	###
    internal function to get the options for the available histories
    ###
	_getOptionsForSelect: () ->
		_options = ["<option value=''>Recent List</option>"];
		@getHistories().forEach (item) =>
			_options.push $("<option value='#{item}'>#{item}</option>")
		_options

	###
    to refresh the list in select box
    @example
    	ce.refreshHistories()
	###
	refreshHistories: () ->
		select = $ "select##{@gid}_histories"
		_options = @_getOptionsForSelect()
		select.find("option").remove()
		select.append _options
