## -------------------------------------------------------------------------------------------------------------
## class FormWrapper to handle the entire form with FormField
##
class FormWrapper

    ## -------------------------------------------------------------------------------------------------------------
    ## constructor
    ##
    constructor: () ->
        # @property [Array] fields fields currently included in the formWrapper
        @fields = []

        # @property [String] gid unique id of the formWrapper
        @gid    = "form" + GlobalValueManager.NextGlobalID()

        # @property [String] templateFormFieldText template to use in the render of form
        @templateFormFieldText = Handlebars.compile '''
            <div class="form-group">
                <label for="{{fieldName}}" class='control-label col-sm-2'> {{label}} </label>
                <div class='col-sm-10'>
                        <input class="form-control" type="{{type}}" id="{{fieldName}}" value="{{value}}" name="{{fieldName}}"
                            {{#each attrs}}
                            {{@key}}="{{this}}"
                            {{/each}}
                        />
                    <div id="{{fieldName}}error" class="text-danger"></div>
                </div>
            </div>
        '''

        @templateSelectFieldText = Handlebars.compile '''
            <div class="form-group">
                <label for="{{fieldName}}" class='control-label col-sm-2'> {{label}} </label>
                <div class='col-sm-10'>
                        <select class="form-control" id="{{fieldName}}" name="{{fieldName}}"
                            {{#each attrs}}
                            {{@key}}="{{this}}"
                            {{/each}}
                        >
                            {{#each options}}
                                <option value="{{this}}">{{this}}</option>
                            {{/each}}
                        </select>
                    <div id="{{fieldName}}error" class="text-danger"></div>
                </div>
            </div>
        '''

    ## -------------------------------------------------------------------------------------------------------------
    ## Add a text input field
    ##
    ## @param [String] fieldName name of the input field
    ## @param [String] label label to be displayed infornt of text input
    ## @param [String] value default value to be filled
    ## @param [Object] attrs object as attributes that will be included in the html
    ## @param [Function] fnValidate a validation function can be passed if it returns true value will be valid else invalid
    ##
    addTextInput: (fieldName, label, value,attrs, fnValidate) =>
        @addInput(fieldName,label,value,"text",attrs,fnValidate)

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

        field = @addInput(fieldName, label, value, "text", attrs, fnValidate)

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
    addMultiselect: (fieldName, label, value, attrs, fnValidate) =>
        attrs = $.extend attrs,
            multiple: 'multiple'

        field = @addInput(fieldName, label, value, "select", attrs, fnValidate)

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
    ## @param [String] fieldName name of the input field
    ## @param [String] label label to be displayed infornt of text input
    ## @param [String] value default value to be filled
    ## @param [String] type type of the input it can be any valid type attribute value default is text
    ## @param [Object] attrs object as attributes that will be included in the html
    ## @param [Function] fnValidate a validation function can be passed if it returns true value will be valid else invalid
    ##
    addInput: (fieldName, label, value, type = "text",attrs = {},fnValidate) =>
        type = if type is "boolean" then "checkbox" else type
        if type is "checkbox" and value is 1
            attrs.checked = "checked"
        value = if type is "checkbox" then 1 else value
        field = new FormField(fieldName, label,value, type, attrs)
        @fields.push(field)
        return field

    ## -------------------------------------------------------------------------------------------------------------
    ## Generate html for the formWrapper
    ##
    ## @return [String] content the html content after compilation under handlebar
    ##
    getHtml: () =>

        content = "<form id='#{@gid}' class='form-horizontal' role='form'>"

        for field in @fields
            if field.type is 'select'
                ##| parse given options and remove from attributes
                field.options = field.attrs.options
                delete field.attrs.options
                content += @templateSelectFieldText(field)
            else
                content += @templateFormFieldText(field)

        content += "</form>";

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
            console.log field.el.val(),field.fieldName
            this[field.fieldName] = field.el.val()
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

        @elForm = $("##{@gid}")
        firstField = null
        for field in @fields
            field.el = @elForm.find("##{field.fieldName}")
            console.log "Calling onAfterShow for field:", field
            field.onAfterShow()
            if !firstField
                firstField = field
                firstField.el.focus()

            field.onPressEnter = (e)=>
                console.log "field.onPressEnter:", e
                @onSubmitAction(e)

        @elForm.on "submit", @onSubmitAction
        true
