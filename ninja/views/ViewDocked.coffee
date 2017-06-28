##|
##|  Options:
##|  locationName = top, left, right, bottom
##|  size = number of pixels by default
##|

class ViewDocked extends View

    constructor   : () ->
        super()

        @optionData = {}
        @optionData.locationName = "top"
        @optionData.size         = 50

    setLocationName: (locationName)=>
        @optionData.locationName = locationName
        @resetSize()
        true

    setDockSize: (size)=>
        @optionData.size = size
        @resetSize()
        true

    getMinWidth: ()=>
        ##|
        ##|  The minimum width is the total of the minimums
        total = 0
        min1 = @first.getMinWidth() || 0
        min2 = @second.getMinWidth() || 0
        if min1 < @optionData.size and (@optionData.locationName == "left" or @optionData.locationName == "right") then min1 = @optionData.size
        if min1? and typeof min1 == "number" then total += min1
        if min2? and typeof min2 == "number" then total += min2
        total += @optionData.gutterSize
        return total

    getMinHeight: ()=>
        ##|
        ##|  The minimum width is the total of the minimums
        total = 0
        min1 = @first.getMinHeight() || 0
        min2 = @second.getMinHeight() || 0
        if min1 < @optionData.size and (@optionData.locationName == "top" or @optionData.locationName == "bottom") then min1 = @optionData.size
        if min1? and typeof min1 == "number" then total += min1
        if min2? and typeof min2 == "number" then total += min2
        total += @optionData.gutterSize
        return total

    calculateSizes: ()=>

        w = @width()
        h = @height()

        ##|
        ##|  If not showing, do nothing yet
        if w == 0 or h == 0 then return

        if @optionData.locationName == "left" or @optionData.locationName == "right"

            @size1 = @optionData.size
            minWidth = @first.getMinWidth() || 0
            if minWidth > @size1 then @size1 = minWidth
            maxWidth = @first.getMaxWidth() || 0
            if maxWidth > 0 and @size1 > maxWidth then @size1 = maxWidth

        else

            @size1 = @optionData.size
            minHeight = @first.getMinHeight()
            if minHeight > @size1 then @size1 = minHeight
            maxHeight = @first.getMaxHeight()
            if maxHeight > 0 and @size1 > maxHeight then @size1 = maxHeight

        true

    onResize: (w, h)=>
        super(w, h)
        @calculateSizes()

        if @optionData.locationName == "left"
            @first.move 0, 0, @size1, h
            @second.move @size1, 0, w-@size1, h
        else if @optionData.locationName == "right"
            @first.move w-@size1, 0, @size1, h
            @second.move 0, 0, w-@size1, h
        else if @optionData.locationName == "top"
            @first.move 0, 0, w, @size1
            @second.move 0, @size1, w, h-@size1
        else
            @first.move 0, h-@size1, w, @size1
            @second.move 0, 0, w, h-@size1

        true

    setSize: (w, h)=>

        if globalDebugResize
            console.log "ViewDocked setSize #{w}, #{h}", @optionData

        super(w, h)
        @setupHolders()
        @calculateSizes()
        true

    ##|
    ##|  Setup the actual splitter window
    setupHolders: ()=>

        if @first? and @second? then return true

        @first  = @addDiv "splitterPartLeft"
        @second = @addDiv "splitterPartRight"
        true

    setData: (options) =>

        if options?
            $.extend @optionData, options, true

        @setupHolders()
        true

    ##|
    ##|  get the main content shortcut
    getBody: ()=>
        return @second

    getFirst: ()=>
        return @first

    getSecond: ()=>
        return @second

