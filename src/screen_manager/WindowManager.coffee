##
##  Window manager adds a wrapper into a div that allows for a toolbar.
##|

class WindowManager

    # @property [Boolean] allowHorizontalScroll if horizontal scrollable default false
    allowHorizontalScroll: false

    constructor: (holderElement)->

        @elWindowManagerOutside = new WidgetTag "div", "windowManager outside"
        @elToolbar = @elWindowManagerOutside.addDiv "toolbar"
        @elContent = @elWindowManagerOutside.addDiv "windowcontent"

        ##|
        ##|  Create a widget for the outside of the window manager and then attach it to the base element
        if typeof holderElement == "string"
            @elHolder = $("#" + holderElement.replace("#",""))
        else if typeof holderElement == "object" and holderElement.el?
            @elHolder = holderElement.el
        else
            @elHolder = $(holderElement)

        @elHolder.append(@elWindowManagerOutside.el)
        @elHolder.on "resize", @onResizeHolder
        @elContent.on "resize", @onResizeContent
        @elWindowManagerOutside.on "resize", @onResizeContent2

    onResizeContent2: (e)=>
        console.log "WindowManager onResizeContent2:", e
        true

    onResizeContent: (e)=>
        console.log "WindowManager onResizeContent:", e
        true

    onResizeHolder: (e)=>
        console.log "WindowManager onResizeHolder:", e
        true

    setContent: (html)->
        @elContent.html html

    setScrollable: ()=>

        @elScrollable    = @elContent.addDiv "scrollable"
        @elWindowWrapper = @elScrollable.addDiv "scrollcontent"

        @myScroll = new IScroll @elWindowWrapper,
            mouseWheel:       true
            scrollbars:       true
            bounce:           false
            resizeScrollbars: false
            freeScroll:       @allowHorizontalScroll
            scrollX:          @allowHorizontalScroll