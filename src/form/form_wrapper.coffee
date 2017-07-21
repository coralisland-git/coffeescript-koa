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

        Handlebars.registerHelper("getNumber", (data)->
            for key, value of data
                if key is "number"
                    return value
            return null
        )

        # @property [String] templateFormFieldText template to use in the render of form
        @templateFormFieldText = Handlebars.compile '''
            <div class="form-group
                {{#if hasError}}
                 has-error"
                {{else}}
                "
                {{/if}}
            >
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

        @templateFormSubmitButton = Handlebars.compile '''
            <div class="form-group centered-with-padding">
                <label for="{{fieldName}}" class='control-label padding-right-label'> {{label}} </label>
                <button class="btn btn-sm btn-primary" type="submit" data-dismiss="modal"
                    {{#each attrs}}
                    {{@key}}="{{this}}"
                    {{/each}}
                ><i class="fa fa-check"></i> {{submit}}</button>
            </div>
        '''

        @templatePathField = Handlebars.compile '''
            <div class="form-group">
                <label for="{{fieldName}}" class='control-label col-sm-2 label-pathfield'> {{label}} </label>
                <div class='col-sm-10 pathfield' id='pathfield-widget-{{getNumber attrs}}'>
                    <!--
                    Here, path-field input will be put on
                    -->
                </div>
            </div>
        '''
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
            multiple: 'multiple'

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
            #"pathfield-widget" : widget
            "number" : @fields.length
        }
        @fields.push field       
        field
    ## -------------------------------------------------------------------------------------------------------------
    ## Append element of each path-field widget tag to form
    ##
    appendPathFieldWidgets: () =>
        for field in @fields
            if field.type is "pathfield"
                widget = field.attrs["pathfield-widget"]
                @elementHolder.find("#pathfield-widget-#{field.attrs['number']}").empty()
                @elementHolder.find("#pathfield-widget-#{field.attrs['number']}").append widget.getTag()

    ## -------------------------------------------------------------------------------------------------------------
    ## Set data path of fields in this form
    ##
    setPath: (tableName, idValue) =>
        for field in @fields
            if field.type is "pathfield"
                widget = field.attrs["pathfield-widget"]
                widget.bindToPath tableName, idValue, field.attrs["column"]
        true
            
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
            else if field.type is 'submit'
                content += @templateFormSubmitButton(field)
            else if field.type is 'pathfield'
                content += @templatePathField(field)
            else
                content += @templateFormFieldText(field)

        content += "</form>"
        return content

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
            this[field.fieldName] = field.el.val()
            if field.hasError
                @show()
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
            field.el = elForm.find("##{field.fieldName}")
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
        @elementHolder.append @wgt_Form.getTag()
        ###@elementHolder.empty()
        @elementHolder.append @getHtml()
        @appendPathFieldWidgets()###
        setTimeout ()=>
                @onAfterShow()
            , 10
        true

    getContent: () =>
        #@elementHolder.append @getHtml()
        #@appendPathFieldWidgets()
        return @elementHolder#.html()

    ## ------------------------------------------------------------------------------------------------------------------
    ## Function to give responsive effect to form elements when
    ## width of form gets shorter than boundary value (currently 400px)
    ## @return [Boolean]

    putElementsFullWidth: ()=>
        if @isFullWidth
            return
        console.log "Make Full Width"
        inputElements = @elementHolder.find "div[class^=col-sm-]"
        inputElements.addClass "form-input-fullwidth-custom"
        
        labelElements = @elementHolder.find "label"
        labelElements.addClass "form-label-fullwidth-custom"

        buttonElements = @elementHolder.find "button"
        buttonElements.addClass "form-button-fullwidth-custom"
        @isFullWidth = true

    ## ------------------------------------------------------------------------------------------------------------------
    ## Function to take away responsive effect from form elements
    ## @return [Boolean]

    backElementsFullWidth: ()=>
        if !@isFullWidth
            return
        console.log "Take off Full Width"
        inputElements = @elementHolder.find "div[class^=col-sm-]"
        inputElements.removeClass "form-input-fullwidth-custom"
        
        labelElements = @elementHolder.find "label"
        labelElements.removeClass "form-label-fullwidth-custom"

        buttonElements = @elementHolder.find "button"
        buttonElements.removeClass "form-button-fullwidth-custom"
        @isFullWidth = false
