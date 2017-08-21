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


NOTES:

setData is called before the view is showing

###

class View extends NinjaContainer

    windowTitle : "** Unknown View **"

    ## Initialize the screen object and store the views's main class
    constructor   : () ->

        super()

        if @classid?
            ##|
            ##|  Look for HTML elements defined in the PUG file and
            ##|  convert them to class members. TODO:  This should use
            ##|  Widgets instead of jQuery
            ##|
            $(@classid).each (idx, el) =>
                @internalFindElements(el)
                true

        ##|
        ##|  Event manager for Event Emitter style events
        GlobalClassTools.addEventManager(this)

    ##|
    ##|  Returns a list of other files to be loaded
    getDependencyList: ()->
        return null



    closePopup: ()=>
        @popup?.destroy()
        delete @popup

    showPopup: (optionalName, w, h, config = null)=>

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
        if !config.tableName? then config.tableName = optionalName
        if !config.scrollable? then config.scrollable = false
        if !config.w? then config.w = w
        if !config.h? then config.h = h
        @popup = new PopupWindow @windowTitle, x, y, config

        console.log "--------------------------------------------------------------"
        console.log "showPopup is broken - Don't use it???"
        console.log "--------------------------------------------------------------"

        ##|
        ##|  Append the view's HTML
        @gid = "View" + GlobalValueManager.NextGlobalID()
        @wgt_elHolder = @add "div", "popupView #{@constructor.name}", "#{@gid}"
        @wgt_elHolder.onResize = (x,y)=>
            console.log "View.cofff wgt_elHolder.onResize(#{x}, #{y})"
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
            @emitEvent "view_ready", []

        ##|
        ##|  Put the HTML template into the new popup window
        @elHolder.html this.template

        true

    setHolder: (@elHolder)=>
        super(@elHolder)
        @elHolder.html this.template
        @internalFindElements(@el)
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

    ##|
    ##|  Called when someone wants the control to resize
    ##|  The NinjaContainer version is good for general use
    # setSize: (w, h)=>

    ##|
    ##|  Called after the control has changed size for some reason
    ##|  The NinjaContainer version is good for general use
    # onResize: (a, b)=>

    ##
    ##  Helper functions used by all the screens
    resetAllInputs = () ->
        $("input[type=text], textarea").val ""
        $("input[type=number], textarea").val ""
