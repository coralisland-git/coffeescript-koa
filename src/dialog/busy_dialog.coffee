## -------------------------------------------------------------------------------------------------------------
## class BusyDialog to show the processing block ui
##

class BusyState

    text : ""
    min  : 0
    max  : 0
    pos  : 0

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
            <div class="modal-body">
                <h4 id='pleaseWaitDialogTitle'>{{content}}</h4>

                <div class="progress" style='display: none;'>
                  <div id='busyProgressBar' class="progress-bar progress-bar-striped active" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%">
                  </div>
                </div>
                <div class="spinner" style='display: none;'>
                    <i class='fa fa-3x fa-asterisk fa-spin'></i>
                </div>

                <div class='progressTextUnder'>Loading</div>
            </div>
        </div>
        '''

        # @property [String] pleaseWaitHolder the html for the holder
        @pleaseWaitHolder = $("body").append @template(this)

        # @property [JQueryElement] modal the currently showing modal
        @modal = $("#pleaseWaitDialog")

        # @property [JQueryElement] elTitle the element in which the dialog is rendered
        @elTitle        = $("#pleaseWaitDialogTitle")
        @elProgressBar  = $("#busyProgressBar")
        @elProgressText = @modal.find(".progressTextUnder")
        @elProgressDiv  = @modal.find(".progress")
        @elSpinner      = @modal.find(".spinner")

        @modal.hide()

    ## -------------------------------------------------------------------------------------------------------------
    ## function to make the processing finish
    ##
    finished: () =>

        @busyStack.pop()

        if @busyStack.length > 0
            @currentState = @busyStack[@busyStack.length-1]
            @updatePercent()
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

    step: (amount = null)=>
        if !amount? or typeof amount != "number" then amount = 1
        if @currentState.max == 0 then @currentState.max = 100
        @currentState.pos++
        @updatePercent()

    setMinMax: (min, max, newPos = null)=>

        @currentState.min = min
        @currentState.max = max
        @updatePercent(newPos)

    updatePercent: (newPos = null)=>

        # console.log "updatePercent stack:", @busyStack
        # console.log "Current:", @currentState

        if newPos? then @currentState.pos = newPos

        @elTitle.html @currentState.text

        if @currentState.pos == 0 and @currentState.max == 0
            @elProgressDiv.hide()
            @elSpinner.show()
            @elProgressBar.attr("aria-valuenow", 0).css("width", 0)
        else
            @elProgressDiv.show()
            @elSpinner.hide()

            percent = Math.floor((@currentState.pos / @currentState.max) * 100) + "%"
            if @currentState.pos+1 == @currentState.max then percent = "100%"

            @elProgressText.html "#{@currentState.pos+1} of #{@currentState.max} (#{percent})"
            @elProgressBar.css("width", percent)
            @elProgressBar.attr
                "aria-valuenow" : @currentState.pos
                "aria-valuemin" : @currentState.min
                "aria-valuemax" : @currentState.max

        true

    ## -------------------------------------------------------------------------------------------------------------
    ## function to show the busy dialog
    ##
    ## @param [String] strText text to show on the modal
    ## @param [Object] options to handle the behaviour of the modal
    ##
    showBusy: (strText, options) =>

        state = new BusyState()
        state.text = strText

        @busyStack.push state
        @currentState = state

        ##
        ##  Possibly overwrite default options
        if typeof options == "object"
            for name, val of options
                this[name] = val

        @updatePercent()

        ##|
        ##|  Create the new html
        @showing = true

        @show()

    ## -------------------------------------------------------------------------------------------------------------
    ## function to show the modal at proper position
    ##
    ## @param [Object] options options to handle behaviour
    ##
    show: () =>

        w = $(window).width()
        h = $(window).height()

        otop = $(window).scrollTop()

        mw = @modal.width()
        mh = @modal.height()

        # console.log "Window (#{w} x #{h}) offset (#{otop}) modal (#{mw} x #{mh})"

        left = (w-mw)/2
        top  = (h-mh)/2

        @modal.show()
        @modal.css
            position : "fixed"
            left     : left
            top      : top

$ ->

    ## -------------------------------------------------------------------------------------------------------------
    ## on document ready creating global object of BusyDialog
    ##
    window.globalBusyDialog = new BusyDialog()
