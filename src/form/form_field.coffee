## -------------------------------------------------------------------------------------------------------------
## function to get function with the matcher regex object
##
## @param [Array] strs arra of strings to handle
## @return [Function] function to check match against the passed strings
##
substringMatcher = (strs) ->
    return (q, cb) ->
        matches = []
        substrRegex = new RegExp(q, 'i')
        for o in strs
            if substrRegex.test o
                matches.push o
        cb matches

## -------------------------------------------------------------------------------------------------------------
## class FormField to handle the single FormField and its rendering
##
class FormField

    submit: "Submit"
    focused: false

    @WARNING: -1
    @ERROR: 0
    @SUCCESS: 1

    ## -------------------------------------------------------------------------------------------------------------
    ## constructor
    ##
    ## @param [String] fieldName name of the field to give inside html
    ## @param [String] label label to be displayed before the form field
    ## @param [String] value the initial value to be set in the form field
    ## @param [String] type the value of the parameter can be any valid type attribute value for ex. text|radio|checkbox etc.
    ## @param [Object] attrs additional attributes to render during the render
    ##
    constructor: (@holderWidget, @fieldName, @label, @value, @type, @attrs = {}, @fnValidate) ->
        #@html = @getHtml()

    ## -------------------------------------------------------------------------------------------------------------
    ## returns the compiled html of the current form field
    ##
    ## @return [String] compiled html string
    ##
    getHtml: () =>
        return "<input name='#{@fieldName}' id='#{@fieldName}' type='#{@type}' value='#{@value}' class='form-control' />"

    ## -------------------------------------------------------------------------------------------------------------
    ## function to make current form field into typeahead
    ##
    ## @param [Object] options options that to be used inside typeahead
    ##
    makeTypeahead: (options) =>
        @typeaheadOptions = options

    ## -gao
    ## function to set focus automatically
    setFocus: ()=>
        @focused = true

    ## -------------------------------------------------------------------------------------------------------------
    ## callback function to be called when enter is pressed
    ##
    onPressEnter: () =>
        ## do nothing

    ## -------------------------------------------------------------------------------------------------------------
    ## callback funciton to be called when escape key is pressed
    ##
    onPressEscape: () =>
        ## do nothing

    ## -------------------------------------------------------------------------------------------------------------
    ## function to be called after the element is visible on the screen
    ##
    onAfterShow: () =>
        if !@el then return false
        if @typeaheadOptions?
            @el.addClass ".typeahead"
            @el.typeahead
                hint: true
                highlight: true
                minLength: 1
            ,
                name: 'options'
                source: substringMatcher(@typeaheadOptions)

            @el.bind "typeahead:select", (ev, suggestion) =>
                console.log "DID CHANGE:", suggestion

        ## -gao
        ## set focus to this element after created
        if @focused then @el.focus()

        @el.bind "keypress", (e) =>
            if e.keyCode == 13
                @onPressEnter(e)
                return false

            if e.keyCode == 27
                @onPressEscape(e)
                return false

            return true
        @el.bind "keyup", (e)=>
            @value = @el.val()

        if @fnValidate? and typeof @fnValidate is "function"
            @el.bind "blur", (e)=>
                @checkError()

    setErrorMsg: (@errorMsg)=>

    setWarningMsg: (@warningMsg)=>

    checkError: ()=>
        unless @fnValidate? and typeof @fnValidate is "function"
            return false
        switch @fnValidate(@value)
            when FormField.SUCCESS
                @hasError = false
                @hasWarning = false
                @hideError()
                return false
            when FormField.WARNING
                @hasError = false
                @hasWarning = true
                @showWarning()
                return true
            when FormField.ERROR
                @hasError = true
                @hasWarning = false
                @showError()
                return true

    showError: ()=>
        @resetErrorFields()
        @formGroupWidget.addClass "has-error"
        @inputWidget.addClass "form-control-danger"
        if !@divError
            @divError = @divWidget.addDiv "text-danger", "#{@fieldName}-error"
        @divError.text @errorMsg

    showWarning: ()=>
        @resetErrorFields()
        @formGroupWidget.addClass "has-warning"
        @inputWidget.addClass "form-control-warning"
        if !@divWarning
            @divWarning = @divWidget.addDiv "text-warning", "#{@fieldName}-warning"
        @divWarning.text @warningMsg

    hideError: ()=>
        @resetErrorFields()
        @formGroupWidget.addClass "has-success"
        @inputWidget.addClass "form-control-success"
        if @divError
            @divError.text ''
        if @divWarning
            @divWarning.text ''

    resetErrorFields: () =>
        @formGroupWidget.removeClass "has-error"
        @formGroupWidget.removeClass "has-warning"
        @formGroupWidget.removeClass "has-success"
        @inputWidget.removeClass "form-control-warning"
        @inputWidget.removeClass "form-control-danger"
        @inputWidget.removeClass "form-control-success"
        if @divError
            @divError.text ''
        if @divWarning
            @divWarning.text ''

    renderText: () =>
        @formGroupWidget = @holderWidget.addDiv "form-group"
        @labelWidget = @formGroupWidget.add "label", "control-label col-sm-2", "", 
            for: "#{@fieldName}"
        @labelWidget.text @label
        @divWidget = @formGroupWidget.add "div", "col-sm-10"
        @inputWidget = @divWidget.add "input", "form-control", "#{@fieldName}", 
            type: "text"
        @inputWidget.val @value

        @el = @inputWidget.el

    renderSelect: () =>
        @formGroupWidget = @holderWidget.addDiv "form-group"
        @labelWidget = @formGroupWidget.add "label", "control-label col-sm-2", "", 
            for: "#{@fieldName}"
        @labelWidget.text @label
        @divWidget = @formGroupWidget.add "div", "col-sm-10"
        @selectWidget = @divWidget.add "select", "form-control", "#{@fieldName}", @attrs

        for option in @attrs.options
            @selectWidget.add "option", "", "", 
                value: "#{option}"
            .text "#{option}"

        @el = @selectWidget.el

    renderSubmit: ()=>
        @formGroupWidget = @holderWidget.addDiv "form-group"
        @labelWidget = @formGroupWidget.add "label", "control-label col-sm-2", "", 
            for: "#{@fieldName}"
        @labelWidget.text @label
        @attrs["data-dismiss"] = "modal"
        @divWidget = @formGroupWidget.addDiv "padding-x-15 col-sm-10"
        @buttonWidget = @divWidget.add "button", "btn btn-sm btn-primary", "", @attrs

        @iconWidget = @buttonWidget.add "i", "fa fa-check"
        @spanWidget = @buttonWidget.add "span"
        @spanWidget.text " #{@submit}"

    renderPathField: ()=>
        @formGroupWidget = @holderWidget.addDiv "form-group"
        @labelWidget = @formGroupWidget.add "label", "control-label col-sm-2 label-pathfield", ""
        @labelWidget.text @attrs.columnName
        @divWidget = @formGroupWidget.add "div", "col-sm-10 pathfield", "pathfield-widget"
        @divPathWidget = @divWidget.add "div", "form-pathfield form-control", "form-widget-#{@attrs.number}"
        @divPathWidget.bindToPath @attrs.tableName, @fieldName, @attrs.columnName                    
        @el = @divPathWidget.el     

    render: ()=>
        switch @type
            when "select" then @renderSelect()
            when "submit" then @renderSubmit()
            when "pathfield" then @renderPathField()
            else @renderText()
