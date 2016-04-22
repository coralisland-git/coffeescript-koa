##| CodeEditor Widget to edit the source code in the web app
##|
##| example usage:
##| ce = new CodeEditor($('#test'), "mysql");
##| @param [jQuery Element] elementHolder in which the code editor will be rendered
##| @param [String] mode to make mysql or javascript editor
##|

class CodeEditor

	# @property [Object] private property to hold the editor instance for future reference and operations
	_editor = null

	# @property [String] languageMode to decide which type of language is supported by the current editor instance
	languageMode = "mysql"

	# @property [Object] _options to set the options to the editor
	_options = {}

	# @property [Array] _histories to access the recent usage of the code
	_histories = []

	## ----------------------------------------------------------------------------------------------------------------
	## constructor to initialize the object of the class
	##
	## @example ce = new CodeEditor $("#editor"), "mysql"
	## @param elementHolder [jQuery Element] the $() referenced element that will hold the editor
    ## @param languageMode [String] the language mode of the editor default is mysql
    ## @return this [CodeEditor] returns instance
	##
	constructor: (@elementHolder, @languageMode = "mysql") ->
		if !@elementHolder.length
			throw new Error "The specified element #{@elementHolder.selector} not found"

		##| check if ace is loaded
		if typeof ace == "undefined"
			throw new Error "Ace editor is not loaded this component depends on ace, so ace editor must be loaded first"

		ace.require("ace/ext/language_tools")
		@_editor = ace.edit @elementHolder.attr('id')
		@_editor.session.setUseWrapMode(true)
		@setMode @languageMode
		@gid = GlobalValueManager.NextGlobalID()
		@_histories = []
		this


	## -------------------------------------------------------------------------------------------------------------
    ## set the different mode in the editor make sure it should find the necessary js file to load the specified mode
	##
	## @example ce.setMode "php" it will automatically prepend the ace/mode/ in the string
    ## @param [String] languageMode the mode of language to select
    ## @return [CodeEditor] this returns current instance
	##
	setMode: (@languageMode) ->
		@_editor.session.setMode "ace/mode/#{@languageMode}"
		this

	## -------------------------------------------------------------------------------------------------------------
    ## set the theme of the current editor instance
	##
	## @example ce.setTheme "tomorrow_night_eighties" it will automatically prepend the ace/theme/ in the name
    ## @param [String] themeName theme to set in the editor ace/theme prefix will be added automatically
	## @return [CodeEditor] this
	##
	setTheme: (themeName) ->
		@_editor.setTheme "ace/theme/#{themeName}"
		this


	## -------------------------------------------------------------------------------------------------------------
	## set the options to the ace editor, all the valid ace options can be passed
	##
	## @example ce.setOptions
    ##				enableBasicAutocompletion: true
    ## @param [Object] options options to set in the editor
    ## @return [CodeEditor] this returns the current instance
	##
	setOptions: (@_options) ->
		console.log @_options
		@_editor.setOptions @_options
		this

	## -------------------------------------------------------------------------------------------------------------
	## make the editor in popup mode to handle tooltip and resize adjustment
	##
	## @example ce.popupMode()
	## @param [Boolean] popupMode
	## @return [CodeEditor] this returns the current instance
	##
	popupMode:(@popupMode = true) ->
		## handles resize
		@elementHolder.parents('.scrollcontent').on "resize", (e) =>
			@_editor.resize()

		@setOptions
			tooltipFollowsMouse: false
		@_editor.addEventListener "guttermousemove",(e) =>
			console.log e.clientX - @elementHolder.offset().left
			setTimeout () =>
				@elementHolder.find(".ace_tooltip").offset({left: 0, top:0})
			,0

		this
	## -------------------------------------------------------------------------------------------------------------
    ## to get the raw ace editor instance
	##
	## @returns [ace] editor
	##
	getInstance: () ->
		@_editor

	## -------------------------------------------------------------------------------------------------------------
    ## to get the current contents of the editor
	##
    ## @return [String] content current content of the code editor
	##
	getContent: () ->
		return @_editor.session.getValue()

	## -------------------------------------------------------------------------------------------------------------
    ## to set the new content in the editor
	##
	## @param [String] content content to be set
    ## @return [CodeEditor] this current instance
	##
	setContent: (content) ->
		@_editor.session.setValue(content)
		this

	## -------------------------------------------------------------------------------------------------------------
    ## to insert content at the current cursor position
	##
	## @param [String] content content to be inserted
    ## @return [CodeEditor] this current instance
	##
	insert: (content) ->
		@_editor.insert(content)
		this

	## -------------------------------------------------------------------------------------------------------------
    ## to register the change handler with editor
	##
	## @example ce.onChange (content,editor) ->
    				#content will be new updated content
    ## @param [Function] changeCallback function to be called on the change with content and editor as argument
    ## @return [CodeEditor] this current instance
	##
	onChange: (@changeCallback) ->
		@_editor.getSession().on 'change', (e) =>
			@changeCallback @getContent(), @_editor

	## -------------------------------------------------------------------------------------------------------------
    ## to add the code into most recent history
	##
	## @example ce.addToHistory "select * from users"
    ## @param [String] code code to insert into recent history
	##
	addToHistory: (code) ->
		if @_histories.indexOf(code) is -1
			@_histories.unshift code
		else
			_index = @_histories.indexOf code
			@internalMoveHistoryItem(_index,0)
		@saveHistory()

	## -------------------------------------------------------------------------------------------------------------
    ## to save history to the local storage
	##
	## @example ce.saveHistory() it will save the current history items in the local storage
	##
	saveHistory: () ->
		##| to save only 100 records
		_histories = JSON.stringify @_histories.slice(0,100)
		localStorage.setItem "_histories_#{@gid}",_histories

	## -------------------------------------------------------------------------------------------------------------
    ## to get save histories from the localstorage
	##
	## @example ce.getHistories()
    ##
	getHistories: () ->
		_histories = localStorage.getItem "_histories_#{@gid}"
		if _histories
			return JSON.parse _histories
		false

	## -------------------------------------------------------------------------------------------------------------
    ## internal function to move order of the array item from one index to another
    ##
	## @param [Integer] oldIndex current index from where to pick element
    ## @param [Integer] newIndex desired index where element should be moved
	##
	internalMoveHistoryItem: (oldIndex,newIndex) ->
		if newIndex >= @_histories.length
			_temp = newIndex - @_histories.length;
			while ((_temp--) + 1)
				@_histories.push undefined
		@_histories.splice(newIndex, 0, @_histories.splice(oldIndex, 1)[0]);
		return this;

	## -------------------------------------------------------------------------------------------------------------
    ## to render the recent histories in select
	##
	## @example ce.renderHistories $(".select"), (value,element) ->
    ##				ce.setContent value
    ## @param [JqueryElement] holder [JqueryElement] reference to jquery element where select should be rendered default it will prepend to code editor holder
    ## @param [Function] changedCallback function to call when select box value is changed
	##
	renderHistories: (holder = null, changedCallback = null) ->
		if !holder
			throw new Error "please provide element to render select box"
		select = $ "<select />"
		select.attr 'id',"#{@gid}_histories"
			.addClass "form-control"
		_options = @internalGetOptionsForSelect()
		select.append _options
		select.on "change", () ->
			if changedCallback
				changedCallback select.val(), select
		holder.html select

	## -------------------------------------------------------------------------------------------------------------
    ## internal function to get the options for the available histories
    ##
	internalGetOptionsForSelect: () ->
		_options = ["<option value=''>Recent List</option>"];
		@getHistories().forEach (item) =>
			_options.push $("<option value='#{item}'>#{item}</option>")
		_options

	## -------------------------------------------------------------------------------------------------------------
    ## to refresh the list in select box
	##
	## @example ce.refreshHistories()
	##
	refreshHistories: () ->
		select = $ "select##{@gid}_histories"
		_options = @internalGetOptionsForSelect()
		select.find("option").remove()
		select.append _options
