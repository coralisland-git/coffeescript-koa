class VirtualScrollArea

    constructor: (holderElement, @isVert, @otherScrollBar)->

        ##|
        ##|  Event manager for Event Emitter style events
        GlobalClassTools.addEventManager(this)

        @min     = 0
        @max     = 0
        @current = 0
        @step    = 1
        @visible = true

        @bottomPadding = 0
        @rightPadding  = 0
        @mySize        = 20

        @backColor              = "#F0F0F0"
        @borderColor            = "1px solid #E7E7E7"
        @thumbBackColor         = "#8F9F8E"
        @thumbBackColorSelected = "#EC9720"

        ##|
        ##|  This is either Horizontal or Vertical
        ##|
        if !@isVert? or !@isVert
            isVert = false

        ##|
        ##|  ElHolder is the container we'll attach to
        ##|
        if typeof holderElement == "object" and holderElement.el?
            @elHolder = holderElement.el
        else if typeof holderElement == "string"
            @elHolder = $("#" + holderElement.replace("#", ""))
        else
            @elHolder = $(holderElement)

        ##|
        ##|  Add the elements
        className = "horiz"
        if @isVert then className = "vert"
        @elScrollTrack = new WidgetTag("div", "vscroll #{className}")
        @thumb = @elScrollTrack.add "div", "marker"

        ##|
        ##| Make the holder element unselectable so drag on it doesn't select text
        @elHolder.css
            '-moz-user-select' : 'none',
            '-webkit-user-select': 'none',
            'user-select': 'none'

        @elHolder.append @elScrollTrack.el
        @resize()
        @setupEvents()

    setRange: (@min, @max, @displaySize, @current) =>

        if @displaySize >= (@max-@min)
            console.log "VirtualScrollArea setRange(min=#{@min}, max=#{@max}, #{@displaySize}, #{@current})", @isVert
            # console.log "VirtualScrollArea setRange hiding, #{@displaySize} >= ", @max-@min
            @hide()
            return
        else
            @show();

        ##|
        ##|  Figure out the spacing

        if (@height() == 0 or @width() == 0)
            setTimeout ()=>
                @setRange @min, @max, @displaySize, @current
            , 10
        else

            if (@max - @min < 1)
                @spacing = 0
            else if @isVert
                @spacing  = @height() / (@max - @min)
            else
                @spacing  = @width() / (@max - @min)

            # console.log "VirtualScrollArea setRange(#{@min}, #{@max}, #{@displaySize}) spacing=#{@spacing}"
            @setPos(@current)

        true

    setPos: (@current)=>

        newOffset = @spacing * @current
        newWidth  = @spacing * @displaySize

        # console.log "VirtualScrollArea setPos(#{@current}), spacing=#{@spacing}, displaySize=#{@displaySize} (newOffset=#{newOffset}, newWidth=#{newWidth})"

        if @isVert
            @thumb.el.css "height", newWidth
            @thumb.el.css "top", newOffset
        else
            newOffset = @spacing * @current
            @thumb.el.css "left", newOffset
            @thumb.el.css "width", newWidth

        true

    onMarkerDragStart: (offsetX, offsetY)=>

        # console.log "OFF=", offsetX, offsetY
        @dragOffsetX = offsetX
        @dragOffsetY = offsetY
        @dragCurrent = Math.floor(@current)

        @dragMarker = true
        @thumb.el.css "backgroundColor", @thumbBackColorSelected

        if @isVert
            @thumb.el.css "cursor", "ns-resize"
            @elScrollTrack.el.css "cursor", "ns-resize"
        else
            @thumb.el.css "cursor", "ew-resize"
            @elScrollTrack.el.css "cursor", "ew-resize"

        true

    onMarkerDragStop: ()=>

        @dragMarker = false
        @thumb.el.css "backgroundColor", @thumbBackColor
        @thumb.el.css "cursor", "grab"
        @elScrollTrack.el.css "cursor", "pointer"
        true

    OnMarkerSet: (pos, maxLoc)=>
        console.log "OnMarkerSet pos=#{pos} maxloc=#{maxLoc}"
        percent = pos / (maxLoc - @thumbHeight)
        console.log "Percent=", percent, "max=#{@max} min=#{@min}"
        num = @min + (percent * (@max - @min))
        console.log "NUM=", num
        @emitEvent "scroll_to", [ Math.floor(num) ]
        true

    setupEvents: ()=>

        @thumbHeight = 18
        @dragMarker  = false

        if @isVert
            @thumb.el.css
                position        : "absolute"
                left            : 1
                right           : 1
                top             : 1
                height          : @thumbHeight
                backgroundColor : @thumbBackColor
                cursor          : "grab"
        else
            @thumb.el.css
                position        : "absolute"
                left            : 1
                top             : 1
                bottom          : 1
                width           : @thumbHeight
                backgroundColor : @thumbBackColor
                cursor          : "grab"

        @elScrollTrack.el.on "mousedown", (e)=>

            if e.target.className == "marker"
                @onMarkerDragStart(e.offsetX, e.offsetY)

            else
                console.log "LOC=", e.offsetX, e.offsetY

                if @isVert
                    if e.offsetY < 10 then e.offsetY = 0
                    @OnMarkerSet e.offsetY, @height()
                else
                    if e.offsetX < 10 then e.offsetX = 0
                    @OnMarkerSet e.offsetX, @width()

            console.log "MOUSE DOWN", e.target.className, e.target.class, e.target
            true

        @elScrollTrack.el.on "mouseup", (e)=>

            if @dragMarker
                @onMarkerDragStop()

            true

        @elScrollTrack.el.on "mousemove", (e)=>
            e.stopPropagation()
            if @dragMarker and e.target.className == "marker"
                x = e.offsetX - @dragOffsetX
                y = e.offsetY - @dragOffsetY
                # console.log "x=#{x} y=#{y} current=#{@current}"

                if @isVert
                    @dragCurrent += (y/@spacing)
                else
                    @dragCurrent += (x/@spacing)

                @setPos(@dragCurrent)

                # console.log "Checking ",Math.floor(@current),@dragCurrent
                if Math.floor(@current) != @dragCurrent
                    # console.log "Fixing loc:", @current, " vs ", @dragCurrent
                    @emitEvent "scroll_to", [ Math.floor(@dragCurrent) ]

            true

        ##|
        ##| mouse out of the marker should not stop scrolling to support scrolling outside of div
        @elScrollTrack.el.on "mouseout", (e)=>
            # if e.target.className != "marker" and e.relatedTarget? and e.relatedTarget.className != "marker"
            #     if @dragMarker
            #         @onMarkerDragStop()
            true

        ##|
        ##| stop scrolling if mouse key is left
        @elHolder.on 'mouseup', (e) =>
            if @dragMarker
                @onMarkerDragStop()

        ##|
        ##| allow scroll outside of scroll div also
        @elHolder.on 'mousemove', (e) =>
            if @dragMarker
                e.stopPropagation()
                x = e.pageX - @elScrollTrack.el.offset().left - @dragOffsetX
                y = e.pageY - @elScrollTrack.el.offset().top - @dragOffsetY
                if @isVert
                    @OnMarkerSet y, @height()
                else
                    @OnMarkerSet x, @width()
            true

        @elHolder.on "DOMMouseScroll", (e)=>
            console.log "THIS:", @isVert, " DOMMouseScroll=", e
            true

        @elHolder.on "wheel", (e)=>

            if !@visible then return true

            # console.log "Wheel:", e.target.className

            ##|
            ##|  Mouse event in some browsers
            ##|
            if e.originalEvent.deltaMode == e.originalEvent.DOM_DELTA_LINE
                deltaX = e.originalEvent.deltaX * -50
                deltaY = e.originalEvent.deltaY * -50
            else
                deltaX = e.originalEvent.deltaX * -1
                deltaY = e.originalEvent.deltaY * -1

            scrollX = Math.ceil(deltaX / 50)
            scrollY = Math.ceil(deltaY / 50)

            e.preventDefault()
            e.stopPropagation()
            if @isVert and scrollY != 0
                @emitEvent "scroll_y", [ scrollY ]
            if not @isVert and scrollX != 0
                @emitEvent "scroll_x", [ scrollX ]

            true

        @elHolder.on "mousewheel", (e)=>
            console.log "THIS:", @isVert, " mousewheel=", e
            true

    hide: ()=>

        @visible = false
        @elScrollTrack.el.hide()
        @elScrollTrack.hide()
        true

    show: ()=>

        @visible = true
        @elScrollTrack.el.show()
        @elScrollTrack.show()
        true

    height: ()=>
        parentHeight = @elHolder.height()
        return parentHeight

    width: ()=>
        parentWidth  = @elHolder.width()
        return parentWidth

    resize: ()=>

        @elScrollTrack.el.css
            position        : "absolute"
            border          : @borderColor
            backgroundColor : @backColor
            fontSize        : "10px"
            padding         : "2px"

        if @isVert
            @elScrollTrack.el.css
                right  : @rightPadding
                top    : 0
                bottom : @bottomPadding
                width  : @mySize
        else
            @elScrollTrack.el.css
                right  : @rightPadding
                bottom : @bottomPadding
                left   : 0
                height : @mySize

        true




