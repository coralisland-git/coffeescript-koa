## -------------------------------------------------------------------------------------------------------------
## class ModalMessageBox to show modal as message box
##
## @extends [ModalDialog]
##
class ModalMessageBox extends ModalDialog

    # @property [String] content the content of the modal
    content:      "Default content"

    # @property [String] title the title of the modal
    title:        "Default title"

    # @property [String] ok text of the button1
    ok:           "Ok"

    # @property [String] close text of the button2
    close:        "Close"

    # @property [Boolean] showFooter to show footer or not
    showFooter:   true

    # @property [Boolean] showOnCreate
    showOnCreate: true

    ## -------------------------------------------------------------------------------------------------------------
    ## constructor
    ##
    ## @param [String] message the message to show in the modal as message
    ##
    constructor: (message) ->

        @showOnCreate = false
        super()

        @title    = "Information"
        @position = 'center'
        @ok       = 'Close'
        @close    = ''
        @content  = message

        @show()


