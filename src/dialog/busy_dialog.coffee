class BusyDialog

    content:       "Processing please wait"
    showing:       false
    busyStack:     []
    callbackStack: []

    constructor:  () ->

        @template = Handlebars.compile '''
        <div class="hidex" id="pleaseWaitDialog">
            <div class="modal-header">
                <h1 id='pleaseWaitDialogTitle'>{{content}}</h1>
            </div>
            <div class="modal-body">
                <div class="progress progress-striped active">
                    <div class="bar" style="width: 100%;"></div>
                </div>
            </div>
        </div>
        '''

        @pleaseWaitHolder = $("body").append @template(this)
        @elTitle          = $("#pleaseWaitDialogTitle")

        @modal = $("#pleaseWaitDialog")
        @modal.hide()

    finished: () =>
        @busyStack.pop()
        if @busyStack.length > 0
            @elTitle.html @busyStack[@busyStack.length-1]
        else
            @modal.hide()
            @showing = false

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

    showBusy: (strText, options) =>

        @busyStack.push strText

        ##
        ##  Possibly overwrite default options
        if typeof options == "object"
            for name, val of options
                this[name] = val

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

    show: (options) =>

        @modal.show()
        @modal.css
            'position' : "fixed"
            left  : () =>
                ($(window).width() - @modal.width()) / 2
            'top' : () =>
                Math.max(0, ($(window).scrollTop() + ($(window).height() - @modal.height()) / 2 ))


$ ->

    window.globalBusyDialog = new BusyDialog()
