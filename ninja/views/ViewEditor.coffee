class ViewEditor extends View

    getDependencyList: ()=>
        return [ "/ace/ace.js", "/ace/ext-language_tools.js" ]

    setupNavbar: ()=>

        ## -gao
        ##  Toolbar button to save/cancel
        ##
        navButtonSave = new NavButton "Save", "toolbar-btn navbar-btn btn-primary"
        navButtonSave.onClick = (e)=>
           console.log "NavBar Save Button clicked.."
           if @saveFunc? and typeof @saveFunc is "function" then @saveFunc(@codeEditor.getContent())
           @closePopup()

        navButtonCancel = new NavButton "Cancel", "toolbar-btn navbar-btn btn-danger cancel-btn"
        navButtonCancel.onClick = (e)=>
            console.log "NavBar Cancel Button clicked.."
            @closePopup()

        @viewNavbar.addToolbar [ navButtonSave, navButtonCancel ]
        true

    ## -------------------------------------------------------------------------------------------------------------
    ## constructor to create new editor
    ##
    showEditor: () =>

        console.log "Setting ViewDocked"
        @setView "Docked", (dockView)=>
            dockView.setDockSize 50
            dockView.getFirst().setView "NavBar", (@viewNavbar)=>
                @editorWidget = dockView.getSecond().addDiv "editor", "editor_" + GlobalValueManager.NextGlobalID()
                @codeEditor = new CodeEditor @editorWidget.getTag()
                @applyCodeEditorSettings()
                @setupNavbar()

    ## -------------------------------------------------------------------------------------------------------------
    ## function to get the created editor instance
    ##
    ## @return [CodeEditor] codeEditor
    ##
    getEditorInstance: ->
        return @codeEditor

    ## -------------------------------------------------------------------------------------------------------------
    ## clears the html of the editor that is used to remove the editor
    ##
    clear: ->
        @editorWidget.html ""

    ## -gao
    ## set function used to save content of editor
    ##
    setSaveFunc: (@saveFunc)=>

    ## -gao
    ## set editor's settings
    ##

    applyCodeEditorSettings: (@codeMode, @content, @theme, @popupMode) =>
        if !@codeEditor? then return false
        if @codeMode then @codeEditor.setMode @codeMode
        if @content then @codeEditor.setContent @content
        if @theme then @codeEditor.setTheme @theme

        if @popupMode? and typeof @popupMode is "boolean" then @codeEditor.popupMode @popupMode

    setEditorTheme: (@theme)=>
        if @codeEditor? and @theme then @codeEditor.setTheme @theme

    setEditorMode: (@codeMode)=>
        if @codeEditor? and @codeMode then @codeEditor.setMode @codeMode

    setEditorPopupMode: (@popupMode)=>
        if @codeEditor? and @popupMode? and typeof @popupMode is "boolean" then @codeEditor.popupMode @popupMode
    
    setEditorOptions: (@_options)=>
        if @codeEditor? and @_options then @codeEditor.setOptions @_options
        this
    setEditorContent: (val) =>

        if !val
            @content = ''
        else if typeof val isnt 'string'
            @content = val.toString()
        else
            @content = val
        if @codeEditor? and @content then @codeEditor.setContent @content

    getEditorContent: ()=>
        @codeEditor.getContent()


