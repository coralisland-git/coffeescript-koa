## -------------------------------------------------------------------------------------------------------------
## class FormWrapper to handle the entire form with FormField
##
class FormWrapper

    ## -------------------------------------------------------------------------------------------------------------
    ## constructor
    ##

    constructor: (holderElement, options) ->

        # @property [String] gid unique id of the formWrapper
        @gid    = "form" + GlobalValueManager.NextGlobalID()
        if !$(holderElement).length
            holderElement = "<form id='#{@gid}' class='form-horizontal' role='form'/>"

        @elementHolder = $ holderElement

        @wgt_Form = new WidgetTag "form", "form-horizontal", "#{@gid}"

        # @property [Array] fields fields currently included in the formWrapper
        @fields = []

        @isFullWidth = false
        @isInlineMode = false

        ##
        ##  Possibly overwrite default options
        if typeof options == "object"
            for name, val of options
                this[name] = val


    ## -------------------------------------------------------------------------------------------------------------
    ## Add a text input field
    ##
    ## @param [String] fieldName name of the input field
    ## @param [String] label label to be displayed infornt of text input
    ## @param [String] value default value to be filled
    ## @param [Object] attrs object as attributes that will be included in the html
    ## @param [Function] fnValidate a validation function can be passed if it returns true value will be valid else invalid
    ##
    addTextInput: (fieldName, label, value, attrs, fnValidate) =>
        @addInput(@wgt_Form, fieldName, label, value, "text", attrs, fnValidate)

    ## -------------------------------------------------------------------------------------------------------------
    ## Add a text input field
    ##
    ## @param [String] fieldName name of the input field
    ## @param [String] label label to be displayed infornt of text input
    ## @param [String] value default value to be filled
    ## @param [Object] attrs object as attributes that will be included in the html
    ## @param [Function] fnValidate a validation function can be passed if it returns true value will be valid else invalid
    ##
    addTagsInput: (fieldName, label, value, attrs, fnValidate) =>

        field = @addInput(@wgt_Form, fieldName, label, value, "text", attrs, fnValidate)

        field.superAfterShow = field.onAfterShow
        field.onAfterShow = ()->

            @el.selectize
                plugins: ['remove_button']
                delimiter: ','
                persist: false
                create: (input) ->
                    console.log "Adding[#{input}]"
                    return { value: input, text: input }

            @superAfterShow()

        field

    ## -------------------------------------------------------------------------------------------------------------
    ## Add a multiselect selectbox
    ##
    ## @param [String] fieldName name of the input field
    ## @param [String] label label to be displayed infornt of text input
    ## @param [String] value default value to be filled
    ## @param [Object] attrs object as attributes that will be included in the html
    ## @param [Function] fnValidate a validation function can be passed if it returns true value will be valid else invalid
    ##
    addMultiselect: (fieldName, label, value, attrs, options = [], fnValidate) =>
        attrs = $.extend attrs,
            'multiple': 'multiple'
            'options': options

        field = @addInput(@wgt_Form, fieldName, label, value, "select", attrs, fnValidate)

        field.superAfterShow = field.onAfterShow
        field.onAfterShow = ()->
            if ! Array.isArray(value)
                value = value.split ','
            @el.multiSelect()
            @el.multiSelect('select', value);
            @superAfterShow()

        field

    ## -------------------------------------------------------------------------------------------------------------
    ## Add a general input field
    ##
    ## @param [WidgetTag] WidgetTag which is to contain input field
    ## @param [String] fieldName name of the input field
    ## @param [String] label label to be displayed infornt of text input
    ## @param [String] value default value to be filled
    ## @param [String] type type of the input it can be any valid type attribute value default is text
    ## @param [Object] attrs object as attributes that will be included in the html
    ## @param [Function] fnValidate a validation function can be passed if it returns true value will be valid else invalid
    ##
    addInput: (holderWidget, fieldName, label, value, type = "text",attrs = {},fnValidate) =>
        type = if type is "boolean" then "checkbox" else type
        if type is "checkbox" and value is 1
            attrs.checked = "checked"
        value = if type is "checkbox" then 1 else value
        field = new FormField(holderWidget, fieldName, label, value, type, attrs, fnValidate)
        @fields.push(field)
        return field
    ## -------------------------------------------------------------------------------------------------------------
    ## Add a submit button field
    ##
    ## @param [String] fieldName name of the input field
    ## @param [String] label label to be displayed infornt of text input
    ## @param [String] value default value to be filled
    ## @param [Object] attrs object as attributes that will be included in the html
    ##
    addSubmit: (fieldName, label, value, attrs = {}) =>
        field = new FormField @wgt_Form, fieldName, label, value, "submit", attrs
        @fields.push field
        field
    
    ## -------------------------------------------------------------------------------------------------------------
    ## Add an input with path of table
    ##
    addPathField: (name, tableName, fieldName, columnName, attrs = {}) =>
        ###widget = new WidgetTag "div", "form-pathfield form-control", "form-widget-#{@fields.length}"
        if attrs.type is "custom"
            widget.removeClass "form-control"
            widget.addClass "custom"
        else if attrs.type is "calculation"
            widget.addClass "calculation"
        ###
        field = new FormField @wgt_Form, fieldName, columnName, "", "pathfield", {
            "tableName" : tableName
            "columnName" : columnName
            "number" : @fields.length
        }
        @fields.push field       
        field
    ## -------------------------------------------------------------------------------------------------------------
    ## function that will be called when a form is submitted
    ##
    ## @event onSubmit function that will be executed on submit of form
    ##
    onSubmit: () =>
        console.log "SUBMIT"

    ## -------------------------------------------------------------------------------------------------------------
    ## function that will be called on form submit
    ##
    ## @param [Event] jquery Event object of submitted form
    ## @return [Boolean]
    ##
    onSubmitAction: (e) =>
        for field in @fields
            if field.checkError()
                console.log "Form is not submitted due to validation error..."
                return false
        @onSubmit(this)
        if e?
            e.preventDefault()
            e.stopPropagation()

        return false

    ## -------------------------------------------------------------------------------------------------------------
    ## function that will be called after the form is rendered and visible
    ##
    ## @return [Boolean]
    ##
    onAfterShow: () =>

        firstField = null
        elForm = $ "##{@gid}"
        for field in @fields
            field.onAfterShow()
            if !firstField
                firstField = field
                firstField.el.focus()

            field.onPressEnter = (e)=>
                console.log "field.onPressEnter:", e
                @onSubmitAction(e)

        elForm.submit @onSubmitAction
        true

    ## ----------------------------------------------------------------------------------------------------------------
    ## Function to show rendered form elements and actions
    ## @return [Boolean]      

    show: () =>
        for field in @fields
            field.render()
            this[field.fieldName] = field
        @elementHolder.append @wgt_Form.getTag()

        setTimeout ()=>
                @onAfterShow()
            , 10
        true

    getContent: () =>
        return @elementHolder

    ## ------------------------------------------------------------------------------------------------------------------
    ## Function to give responsive effect to form elements when
    ## width of form gets shorter than boundary value (currently 400px)
    ## @return [Boolean]

    putElementsFullWidth: ()=>
        if @isFullWidth
            return
        console.log "Make Full Width"

        for field in @fields
            field.divWidget?.addClass "form-input-fullwidth-custom"
            #unless field.type is "submit11"
            field.labelWidget?.addClass "form-label-fullwidth-custom"
            field.buttonWidget?.addClass "form-button-fullwidth-custom"

        @isFullWidth = true

    ## ------------------------------------------------------------------------------------------------------------------
    ## Function to take away responsive effect from form elements
    ## @return [Boolean]

    backElementsFullWidth: ()=>
        if !@isFullWidth
            return
        console.log "Take off Full Width"

        for field in @fields
            field.divWidget?.removeClass "form-input-fullwidth-custom"
            field.labelWidget?.removeClass "form-label-fullwidth-custom"
            field.buttonWidget?.removeClass "form-button-fullwidth-custom"

        @isFullWidth = false

    ## -gao
    ## function to make form inline-style
    ##
    switch2InlineForm: ()=>
        if @isInlineMode 
            return
        console.log "Switch to Inline mode"
        @wgt_Form.removeClass "form-horizontal"
        @wgt_Form.addClass "form-inline"
        for field in @fields
            field.labelWidget?.addClass "form-label-autowidth-custom"
            field.divWidget?.addClass "form-input-autowidth-custom"
        @isInlineMode = true

    ##
    ## function to make form horizontal-style
    ##
    switch2HorizontalForm: ()=>
        if !@isInlineMode
            return
        console.log "Switch to Horizontal mode"
        @wgt_Form.removeClass "form-inline"
        @wgt_Form.addClass "form-horizontal"
        for field in @fields
            field.labelWidget?.removeClass "form-label-autowidth-custom"
            field.divWidget?.removeClass "form-input-autowidth-custom"
        @isInlineMode = false
