###

A View is a managed class that contains Javascript, and HTML Template, and a CSS file
The base view code is loaded on demand from the server.   Something should extend this
base view class to implement specific actions.

The base class handles adding the CSS to the document, adding the HTML template to the
DOM and setting up variables based on the template.

from showPopup:
@property elHolder [jQUery]         Contains the holder element
@property popup    [PopupWindow]    Popup window object from Ninja
@property gid      [text]           A unique ID used as the elHolder id

###

class View

    windowTitle : "** Unknown View **"

    ## Initialize the screen object and store the views's main class
    constructor   : () ->

        @gid = GlobalValueManager.NextGlobalID()

        $(@classid).each (idx, el) =>
            @internalFindElements(el)
            true

        ##|
        ##|  Event manager for Event Emitter style events
        GlobalClassTools.addEventManager(this)

        #globalTableEvents.on "resize", @onResize
        @on "resize", @onResize


    ##|
    ##|  Returns a list of other files to be loaded
    getDependencyList: ()->
        return null

    ##|
    ##|  Add a toolbar
    addToolbar: (buttonList) =>

        if @popup?
            @popup.addToolbar buttonList
        else
            console.log "Can't add toolbar to non poup view"

        return

    ##|
    ##|  Add this view to an existing element
    AddToElement: (holderElement)=>

        ##|
        ##|  brian - Allowing view to be added to a Widget directly.
        if holderElement? and typeof holderElement == "object" and holderElement.el?

            @elHolder = holderElement.el
            holderElement.view = this

        else

            ##|
            ##|  Because we are adding CSS, we want to wait until the CSS is loaded
            ##|  before we continue and generate the ready event.
            ##|
            @elHolder = $(holderElement)

        ##|
        ##|  Put the HTML template into the new element
        @elHolder.addClass @constructor.name
        @elHolder.html this.template

        ##|
        ##|  Append CSS
        cssTag = $ "<style>#{this.css}</style>"
        $("head").append(cssTag)

        ##|
        ##|  Create internal elements
        @internalFindElements @elHolder
        @onShowScreen()

        ##|
        ##|  Must have a timer to allow the event manager to add the CSS to the DOM
        setTimeout ()=>
            @emitEvent "view_ready", []
        , 1

    closePopup: ()=>
        @popup.destroy()
        delete @popup

    showInDiv: (elTarget) =>

        if typeof elTarget == "string"
            @elHolder = $("#" + elTarget.replace("#", ""))
        else
            @elHolder = $(elTarget)

        $(document).ready ()=>
            @internalFindElements @elHolder
            @onShowScreen()
            @emitEvent "view_ready", []

        @elHolder.addClass "viewHolder"
        @elHolder.html this.template

        if this.css? and this.css.length > 0
            cssTag = $ "<style>#{this.css}</style>"
            $("head").append(cssTag)

        true

    showPopup: (optionalName, w, h)=>

        if !w? then w = $(window).width() - 100
        if !h? then h = $(window).height() - 100

        ##
        ## Calculate scrolled position
        scrollX = window.pageXOffset || document.body.scrollLeft
        scrollY = window.pageYOffset || document.body.scrollTop
        
        x = ($(window).width() - w)  / 2 + scrollX
        y = ($(window).height() - h) / 2 + scrollY

        ##|
        ##|  Remove space that title bar takes up
        y -= (34/2)

        @popup = new PopupWindow @windowTitle, x, y,
            tableName: optionalName
            w: w
            h: h

        ##|
        ##|  Append the view's HTML
        @gid = "View" + GlobalValueManager.NextGlobalID()
        # -xg
        console.log "showPopup adding to", @popup.wgt_WindowScroll
        @wgt_elHolder = @popup.wgt_WindowScroll.add "div", "popupView #{@constructor.name}", "#{@gid}"

        @wgt_elHolder.onResize = (x,y)=>
            return @onResize(x, y)

        @elHolder = @wgt_elHolder.el 

        ##|
        ##|  Because we are adding CSS, we want to wait until the CSS is loaded
        ##|  before we continue and generate the ready event.
        ##|

        $(document).ready ()=>

            ##|
            ##|  Create internal elements
            @internalFindElements @elHolder
            @onShowScreen()

            ##|  force a top level resize to any windows that may be open
            setTimeout ()=>
                w = $(window).width()
                h = $(window).height()
                globalTableEvents.emitEvent "resize", [w, h]
            , 10

            @emitEvent "view_ready", []

        ##|
        ##|  Put the HTML template into the new popup window
        @elHolder.html this.template

        ##|
        ##|  Append CSS
        cssTag = $ "<style>#{this.css}</style>"
        $("head").append(cssTag)

        true

    # -xg
    # show popup window with configuration
    showPopupwithConfig: (optionalName, w, h, config)=>

        if !w? then w = $(window).width() - 100
        if !h? then h = $(window).height() - 100

        ##
        ## Calculate scrolled position
        scrollX = window.pageXOffset || document.body.scrollLeft
        scrollY = window.pageYOffset || document.body.scrollTop

        x = ($(window).width() - w)  / 2 + scrollX
        y = ($(window).height() - h) / 2 + scrollY

        ##|
        ##|  Remove space that title bar takes up
        y -= (34/2)

        if !config then config = {}
        config.tableName = optionalName
        config.scrollable = false
        config.w = w
        config.h = h
        @popup = new PopupWindow @windowTitle, x, y, config
            
        ##|
        ##|  Append the view's HTML
        @gid = "View" + GlobalValueManager.NextGlobalID()
        @wgt_elHolder = @popup.wgt_WindowScroll.add "div", "popupView #{@constructor.name}", @gid
        @popup.setView(this)
        @wgt_elHolder.onResize = (x,y)=>
            return @onResize(x, y)
        #@elHolder = $ "<div />",
        #    id: @gid
        #    class: "popupView " + @constructor.name

        @elHolder = @wgt_elHolder.el
        ##|
        ##|  Because we are adding CSS, we want to wait until the CSS is loaded
        ##|  before we continue and generate the ready event.
        ##|

        $(document).ready ()=>

            ##|
            ##|  Create internal elements
            @internalFindElements @elHolder
            @onShowScreen()
            @emitEvent "view_ready", []

        ##|
        ##|  Put the HTML template into the new popup window
        @elHolder.html this.template

        ##|
        ##|  Put the holder element and template into the scrollable
        ##|  section of the popup window.
        #@popup.windowScroll.append @elHolder

        ##|
        ##|  Append CSS
        cssTag = $ "<style>#{this.css}</style>"
        $("head").append(cssTag)
        @popup.emitEvent "resize_popupwindow"

        true


    internalFindElements: (parentTag) =>
        ##|
        ##|  If you find a tag in the template with an id then create the variable automatically
        ##|
        el = $(parentTag)
        id = el.attr "id"

        if id?
            this[id] = el

        el.children().each (idx, el) =>
            @internalFindElements el

    ## called when the screen is about to be displayed
    onShowScreen  : () =>
        @screenHidden = false

    ## called when the screen is about to be hidden
    ## no action is required in most cases
    onHideScreen  : () =>
        @screenHidden = true

    onResize: (a, b)=>
        w = 0
        h = 0
        if @elHolder?
            w = @elHolder.width()
            h = @elHolder.height()
            console.log "View.coffee onResize a=#{a} b=#{b} w=#{w} h=#{h}:", @elHolder.el
            if a? and b? and a > 0 and b > 0
                @elHolder.width(a)
                @elHolder.height(b)

        #@emitEvent "resize", [ w, h ]

    ## called when the screen is reset due to logout or otherwise
    ## no action is required in most cases
    onResetScreen : () =>
        Screen.resetAllInputs()

    ##
    ##  Helper functions used by all the screens
    resetAllInputs = () ->
        $("input[type=text], textarea").val ""
        $("input[type=number], textarea").val ""

    #
    # -xg
    width: () =>
        return @elHolder.width()

    height: () =>
        return @elHolder.height()