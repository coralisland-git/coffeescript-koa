
class VirtualScrollArea

    constructor: (holderElement, @isVert, @otherScrollBar)->

        ##|
        ##|  Event manager for Event Emitter style events
        GlobalClassTools.addEventManager(this)

        @min           = 0
        @max           = 0
        @current       = 0
        @visible       = true
        @bottomPadding = 0
        @rightPadding  = 0
        @mySize        = 20
        @backColor     = "#F0F0F0"
        @borderColor   = "1px solid #E7E7E7"

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
            '-moz-user-select'    : 'none'
            '-webkit-user-select' : 'none'
            'user-select'         : 'none'

        @elHolder.append @elScrollTrack.el

        @resize()
        @setupEvents()

    setRange: (newMin, newMax, newDisplaySize, newCurrent)=>

        # return
        updated = false

        if !newMin? or !newMax? or !newDisplaySize? or !newCurrent? then return false

        if newMin != @min
            @min = newMin
            updated = true

        if newMax != @max
            @max = newMax
            updated = true

        if newDisplaySize != @displaySize
            @displaySize = newDisplaySize
            updated = true

        if newCurrent != @current
            @current = newCurrent
            updated = true

        # console.log "VirtualScrollArea setRange(min=#{@min}, max=#{@max}, #{@displaySize}, #{@current}) [#{updated}]", @isVert

        if updated == false
            return false

        result = false;
        if @displaySize >= (@max-@min)
            # console.log "VirtualScrollArea setRange hiding, #{@displaySize} >= ", @max-@min
            return @hide()
        else
            if @visible == false then result = true
            @show();

        ##|
        ##|  Figure out the spacing

        if (@height() == 0 or @width() == 0)
            setTimeout ()=>
                @current = -1
                @setRange newMin, newMax, newDisplaySize, newCurrent
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

        result

    setPos: (@current)=>

        newOffset = @spacing * @current
        newWidth  = @spacing * @displaySize

        newWidth = Math.floor(newWidth)
        # console.log "VirtualScrollArea setPos(#{@current}), spacing=#{@spacing}, displaySize=#{@displaySize} (newOffset=#{newOffset}, newWidth=#{newWidth}) vis=#{@visible}"

        if @isVert
            @thumb.el.css "height", newWidth
            @thumb.el.css "top", newOffset
        else
            newOffset = @spacing * @current
            @thumb.el.css "left", newOffset
            @thumb.el.css "width", newWidth

        true

    OnMarkerSet: (pos, maxLoc)=>
        percent = pos / (maxLoc - @thumbHeight)
        num = @min + (percent * (@max - @min))
        @emitEvent "scroll_to", [ Math.floor(num) ]
        true

    onMarkerDrag: (diffX, diffY)=>

        if @isVert
            amount = diffY/@spacing
        else
            amount = diffX/@spacing

        # console.log "From #{@dragCurrent} moving #{amount}"
        amount = @dragCurrent + amount

        if amount < 1 then amount = 0
        if amount + @displaySize >= @max then amount = @max - @displaySize
        amount = Math.floor(amount)

        @emitEvent "scroll_to", [ Math.floor(amount) ]
        true

    ##|
    ##|  Called when the thumb slider drag is complete.
    onMarkerDragFinished: (diffX, diffY, e)=>
        true

    onScrollTrackMouseDown: (e) =>

        pos = @elHolder.offset()

        if e.target.className == "marker"
            @dragCurrent = Math.floor(@current)
            GlobalMouseDrag.startDrag(e, @onMarkerDrag, @onMarkerDragFinished)

        else

            if @isVert
                if e.offsetY < 10 then e.offsetY = 0
                @OnMarkerSet e.offsetY, @height()
            else
                if e.offsetX < 10 then e.offsetX = 0
                @OnMarkerSet e.offsetX, @width()

        true

    setupEvents: ()=>

        @thumbHeight = 18
        @document    = $(document)

        if @isVert
            @thumb.el.css
                height : @thumbHeight
                width  : @thumbHeight-2
        else
            @thumb.el.css
                width  : @thumbHeight
                height : @thumbHeight-2

        @elScrollTrack.el.on "mousedown", @onScrollTrackMouseDown

        @elHolder.on "wheel", (e)=>

            if !@visible then return true

            ##|
            ##|  Mouse event in some browsers
            ##|
            if e.originalEvent.deltaMode == e.originalEvent.DOM_DELTA_LINE
                deltaX = e.originalEvent.deltaX * -5
                deltaY = e.originalEvent.deltaY * -5
            else
                deltaX = e.originalEvent.deltaX * -1
                deltaY = e.originalEvent.deltaY * -1

            scrollX = Math.ceil(Math.abs(deltaX)/40)
            scrollY = Math.ceil(Math.abs(deltaY)/40)

            if Math.abs(deltaX) < 10 then scrollX = 0
            if Math.abs(deltaY) < 10 then scrollY = 0

            e.preventDefault()
            e.stopPropagation()
            if @isVert and scrollY != 0
                if e.originalEvent.wheelDelta < 0
                    @emitEvent "scroll_to", [ @current+scrollY ]
                else 
                    @emitEvent "scroll_to", [ @current-scrollY ]
            else if not @isVert and scrollX != 0
                if e.originalEvent.deltaX < 0
                    @emitEvent "scroll_to", [ @current-scrollX ]
                else
                    @emitEvent "scroll_to", [ @current+scrollX ]

            true


    hide: ()=>
        # console.log "Calling Hide on #{@isVert}"
        if @visible == false then return false
        @visible      = false
        @parentHeight = null
        @parentWidth  = null
        @elScrollTrack.el.hide()
        true

    show: ()=>
        # console.log "Calling Show on #{@isVert}"
        # if @visible == true then return false
        @visible      = true
        @parentHeight = null
        @parentWidth  = null
        @elScrollTrack.el.show()
        true

    height: ()=>
        if @parentHeight? and @parentHeight > 0 then return @parentHeight
        @parentHeight = @elHolder.height()
        return @parentHeight

    width: ()=>
        if @oarentWidth? and @parentWidth > 0 then return @parentWidth
        @parentWidth  = @elHolder.width()
        return @parentWidth

    resize: ()=>

        @parentHeight = null
        @parentWidth = null

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




