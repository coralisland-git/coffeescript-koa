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

    ## -------------------------------------------------------------------------------------------------------------
    ## constructor
    ##
    ## @param [String] fieldName name of the field to give inside html
    ## @param [String] label label to be displayed before the form field
    ## @param [String] value the initial value to be set in the form field
    ## @param [String] type the value of the parameter can be any valid type attribute value for ex. text|radio|checkbox etc.
    ## @param [Object] attrs additional attributes to render during the render
    ##
    constructor: (@fieldName, @label, @value, @type, @attrs = {}) ->
        @html = @getHtml()

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

        @el.bind "keypress", (e) =>
            if e.keyCode == 13
                @onPressEnter(e)
                return false

            if e.keyCode == 27
                @onPressEscape(e)
                return false

            return true