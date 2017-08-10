class ViewCodeEditor extends View

    getDependencyList: ()=>
        return [ "/ace/ace.js", "/ace/ext-language_tools.js" ]

    ## -------------------------------------------------------------------------------------------------------------
    ## constructor to create new editor
    ##
    showEditor: () =>
        @editorWidget = @addDiv "editor", "editor_" + GlobalValueManager.NextGlobalID()
        @codeEditor = new CodeEditor @editorWidget.getTag()
        @applyCodeEditorSettings()

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
    ## set editor's settings
    ##

    applyCodeEditorSettings: (@codeMode, @content, @theme, @popupMode) =>
        if !@codeEditor? then return false
        if @codeMode then @codeEditor.setMode @codeMode
        if @content then @codeEditor.setContent @content
        if @theme then @codeEditor.setTheme @theme
        if @popupMode? and typeof @popupMode is "boolean" then @codeEditor.popupMode @popupMode
        this

    setTheme: (@theme)=>
        if @codeEditor? and @theme then @codeEditor.setTheme @theme
        this

    setMode: (@codeMode)=>
        if @codeEditor? and @codeMode then @codeEditor.setMode @codeMode
        this

    setPopupMode: (@popupMode)=>
        if @codeEditor? and @popupMode? and typeof @popupMode is "boolean" then @codeEditor.popupMode @popupMode
        this

    setContent: (val) =>

        if !val
            @content = ''
        else if typeof val isnt 'string'
            @content = val.toString()
        else
            @content = val
        if @codeEditor? and @content then @codeEditor.setContent @content
        this

    getContent: ()=>
        @codeEditor.getContent()
