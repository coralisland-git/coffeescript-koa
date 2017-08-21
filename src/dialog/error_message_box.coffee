## -------------------------------------------------------------------------------------------------------------
## @extends [ModalDialog]
class ErrorMessageBox extends ModalDialog

    # @property [String] content the content of the modal
    content:      "Default content"

    # @property [String] title default title
    title:        "Default title"

    # @property [String] ok text of ok button
    ok:           "Ok"

    # @property [String] close text of close button
    close:        "Close"

    # @property [Boolean] showFooter
    showFooter:   true

    # @property [Boolean] showOnCreate
    showOnCreate: true

    ## -------------------------------------------------------------------------------------------------------------
    ## constructor
    ##
    ## @param [String] message to show the error message inside modal
    ## @return [Boolean]
    ##
    constructor: (message) ->

        @showOnCreate = false
        super()

        console.log "MESSAGE=", message

        @title    = "Error"
        @position = 'center'
        @ok       = 'Close'
        @close    = ''
        @content  = message
        @createModal()
        @show()
