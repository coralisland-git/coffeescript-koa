##
##  This is the template for a generic screen
##

class Screen

    classid          : ""
    initialized      : false
    backButtonText   : ""
    actionButtonText : ""

    windowTitle      : "** Unknown screen **"
    windowSubTitle   : "** windowSubTitle not set **"

    ## Initialize the screen object and store the screen's main class
    constructor   : () ->

        @classid = "#" + @constructor.name + ".screen"
        @firstEvents = true

        if this.css?
            ##|
            ##|  Append CSS
            cssTag = $ "<style type='text/css'>#{this.css}</style>"
            $("head").append(cssTag)

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


    ## called when the screen is reset due to logout or otherwise
    ## no action is required in most cases
    onResetScreen : () =>
        for el in $(@classid)
            @internalFindElements(el)
            true

        true

    ## Called when the object is first initialized in order to setup all the buttons
    onSetupButtons : () =>

    ##
    ##  Helper functions used by all the screens
    resetAllInputs = () ->
        $("input[type=text], textarea").val ""
        $("input[type=number], textarea").val ""

    onResize: (w, h)=>
        ##|
        ##|  Nothing

    getScreenSize: ()=>
        height = $(window).height()
        width  = $(window).width()
        screen = $(@classid)
        pos    = screen.position()
        offset = screen.offset()

        if !height? or height == 0 or !pos? or pos.top == 0
            setTimeout @getScreenSize, 10
            return

        width -= pos.left
        height -= pos.top

        @onResize width, height, @firstEvents
        @firstEvents = false

        return { width: width, height: height }

