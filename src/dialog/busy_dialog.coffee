## -------------------------------------------------------------------------------------------------------------
## class BusyDialog to show the processing block ui
##
class BusyDialog

    # @property [String] content the content to show on the popup
    content:       "Processing please wait"

    # @property [Boolean] showing the status if currenlty showing or not
    showing:       false

    # @property [Array] busyStack information about all the stacks if nested dialogs are used
    busyStack:     []

    # @property [Array] callbackStack stack of the callback to execute
    callbackStack: []

    ## -------------------------------------------------------------------------------------------------------------
    ## constructor
    ##
    constructor:  () ->

        # @property [String] template the template to use in the BusyDialog
        @template = Handlebars.compile '''
        <div class="hidex" id="pleaseWaitDialog">
            <div class="modal-header">
                <h4 id='pleaseWaitDialogTitle'>{{content}}</h4>
            </div>
            <div class="modal-body">
                <div class="progress">
                  <div id='busyProgressBar' class="progress-bar progress-bar-striped active" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%">
                    <span class="sr-only">Working</span>
                  </div>
                </div>
            </div>
        </div>
        '''

        # @property [String] pleaseWaitHolder the html for the holder
        @pleaseWaitHolder = $("body").append @template(this)

        # @property [JQueryElement] elTitle the element in which the dialog is rendered
        @elTitle          = $("#pleaseWaitDialogTitle")

        # @property [JQueryElement] modal the currently showing modal
        @modal = $("#pleaseWaitDialog")

        @modal.hide()

    ## -------------------------------------------------------------------------------------------------------------
    ## function to make the processing finish
    ##
    finished: () =>
        @busyStack.pop()
        if @busyStack.length > 0
            @elTitle.html @busyStack[@busyStack.length-1]
        else
            @modal.hide()
            @showing = false

    ## -------------------------------------------------------------------------------------------------------------
    ## function to execute the dialog
    ##
    ## @param [String] strText text to show on the box
    ## @param [Function] callbackFunction function to execute on the finished
    ##
    exec: (strText, callbackFunction) =>

        @callbackStack.push callbackFunction
        setTimeout () =>
            @showBusy(strText)

            setTimeout () =>
                callbackFunction = @callbackStack.pop()
                if callbackFunction?
                    callbackFunction()
                else
                    console.log "SHOULD NOT BE NULL:", strText, @callbackStack

                @finished()
            , 500

        , 0

    ##|
    ##|  Show busy waiting for data on a promise
    waitFor: (strText, promiseValue, timeout) =>

        @showBusy strText
        new Promise (resolve, reject)=>

            if !timeout? then timeout = 30
            timerValue = setTimeout ()=>
                console.log "Timeout waiting on promise:", strText
                resolve(null)
            , timeout * 1000

            promiseValue.then (result)=>
                clearTimeout timerValue
                @finished()
                resolve(result)


    ## -------------------------------------------------------------------------------------------------------------
    ## function to show the busy dialog
    ##
    ## @param [String] strText text to show on the modal
    ## @param [Object] options to handle the behaviour of the modal
    ##
    showBusy: (strText, options) =>

        @busyStack.push strText

        ##
        ##  Possibly overwrite default options
        if typeof options == "object"
            for name, val of options
                this[name] = val

        $("#busyProgressBar").attr("aria-valuenow", 0).css("width", 0)

        ##|
        ##|  Update the text if already showing
        if @showing
            console.log "Updating to ", strText
            $("#pleaseWaitDialogTitle").html(strText)
            return

        ##|
        ##|  Create the new html
        @showing = true
        @elTitle.html strText

        @show
            position: "center"

    ## -------------------------------------------------------------------------------------------------------------
    ## function to show the modal at proper position
    ##
    ## @param [Object] options options to handle behaviour
    ##
    show: (options) =>

        @modal.show()
        @modal.css
            'position' : "fixed"
            left  : () =>
                ($(window).width() - @modal.width()) / 2
            'top' : () =>
                Math.max(0, ($(window).scrollTop() + ($(window).height() - @modal.height()) / 2 ))


$ ->

    ## -------------------------------------------------------------------------------------------------------------
    ## on document ready creating global object of BusyDialog
    ##
    window.globalBusyDialog = new BusyDialog()
