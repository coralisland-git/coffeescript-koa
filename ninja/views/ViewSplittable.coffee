##|
##|  Options:
##|  sizes = [ percent1, percent2 ] or sizes = percent1
##|  direction = vertical or horizontal
##|  gutterSize = 6 by default
##|

class ViewSplittable extends View

    constructor   : () ->
        super()

        @optionData = {}
        @optionData.direction  = "vertical"
        @optionData.gutterSize = 6
        @optionData.size       = 50

    getMinWidth: ()=>
        ##|
        ##|  The minimum width is the total of the minimums
        total = 0
        min1 = @first.getMinWidth() || 0
        min2 = @second.getMinWidth() || 0
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
        if min1? and typeof min1 == "number" then total += min1
        if min2? and typeof min2 == "number" then total += min2
        total += @optionData.gutterSize
        return total

    onResize: (w, h)=>

        if globalDebugResize
            console.log "ViewSplittable onResize #{w}, #{h}"

        ##|
        ##|  Parent container has changed size.  The parent is now w x h
        if @wdtSplittable?
            @wdtSplittable.setSize(w, h)

        true

    getPercent: ()=>
        return @optionData.size

    ##|
    ##|  Set's the split percent which is p1 and 100-p1 assumed
    setPercent: (p1)=>
        if p1 <= 1.0 and p1 >= 0 then p1 *= 100
        @optionData.size = p1
        @resetSize()
        true

    calculateSizes: ()=>

        w = @width()
        h = @height()

        ##|
        ##|  If not showing, do nothing yet
        if w == 0 or h == 0 then return

        p1 = @optionData.size / 100.0
        if p1 < 0 then p1 = 0
        if p1 > 100 then p1 = 100

        if @optionData.direction == "vertical"

            ##|  vertical split
            space = w - @optionData.gutterSize
            @size1 = space * p1
            @size2 = space - @size1

            minWidth = @first.getMinWidth() || 0
            if @size1 < minWidth then @size1 = minWidth
            @size2 = space - @size1

            minWidth = @second.getMinWidth() || 0
            if @size2 < minWidth then @size2 = minWidth
            @size1 = space - @size2

            @gutter.move @size1, 0, @optionData.gutterSize, h
            @optionData.size = 100*(@size1/w)

        else

            space = h - @optionData.gutterSize
            @size1 = space * p1
            @size2 = space - @size1

            if @first.getMinHeight?
                minHeight = @first.getMinHeight()
                if @size1 < minHeight then @size1 = minHeight
                @size2 = space - @size1

            if @second.getMinHeight?
                minHeight = @second.getMinHeight()
                if @size2 < minHeight then @size2 = minHeight
                @size1 = space - @size2

            @gutter.move 0, @size1, w, @optionData.gutterSize
            @optionData.size = 100*(@size1/h)

        # console.log "calculateSizes w=#{w}, h=#{h} size1=#{@size1}, size2=#{@size2}"

        true

    setSize: (w, h)=>

        if globalDebugResize
            console.log "ViewSplittable setSize #{w}, #{h}", @optionData

        super(w, h)
        @setupSplitter()

        @calculateSizes()

        if @optionData.direction == "vertical"

            @gutter.addClass "vertical"
            @gutter.removeClass "horizontal"

            if globalDebugResize
                console.log "ViewSplittable Vertical sizes=#{@size1}, #{@size2}"

            @first.move 0, 0, @size1, h
            @gutter.move @size1, 0, @optionData.gutterSize, h
            @second.move @size1+@optionData.gutterSize, 0, @size2, h

        else

            @gutter.removeClass "vertical"
            @gutter.addClass "horizontal"

            if globalDebugResize
                console.log "ViewSplittable Horizontal sizes=#{@size1}, #{@size2}"

            @first.move 0, 0, w, @size1
            @gutter.move 0, @size1, w, @optionData.gutterSize
            @second.move 0, @size1+@optionData.gutterSize, w, @size2

        true

    onDragGutter: (deltaX, deltaY, e)=>
        w = @width()
        h = @height()

        if @optionData.direction == "vertical"
            newSize1 = @startingSize1 + deltaX
            @optionData.size = 100*(newSize1/@width())
        else
            newSize1 = @startingSize1 + deltaY
            @optionData.size = 100*(newSize1/@height())

        @calculateSizes()
        true

    onDragGutterComplete: (deltaX, deltaY, e)=>
        @gutter.removeClass "dragging"

        ##|
        ##| Figure out the new percentages
        if @optionData.direction == "vertical"
            newSize1 = @startingSize1 + deltaX
            @optionData.size = 100*(newSize1/@width())
        else
            newSize1 = @startingSize1 + deltaY
            @optionData.size = 100*(newSize1/@height())

        if globalDebugResize
            console.log "ViewSplittable onDragGutterComplete new percent=", @optionData.size, " newSize=", newSize1

        @resetSize()
        true

    ##|
    ##|  Setup the actual splitter window
    setupSplitter: ()=>

        if @first? and @second? then return true

        @first  = @addDiv "splitterPartLeft"
        @gutter = @addDiv "splitterGutter"
        @second = @addDiv "splitterPartRight"

        @gutter.on "mousedown", (e)=>
            @gutter.addClass "dragging"
            @minWidth1  = @first.getMinWidth() || 0
            @minWidth2  = @second.getMinWidth() || 0
            @maxWidth1  = @first.getMaxWidth()
            @maxWidth2  = @second.getMaxWidth()
            @minHeight1 = @first.getMinHeight() || 0
            @minHeight2 = @second.getMinHeight() || 0
            @maxHeight1 = @first.getMaxHeight()
            @maxHeight2 = @second.getMaxHeight()

            @startingSize1 = @size1
            @startingSize2 = @size2

            GlobalMouseDrag.startDrag(e, @onDragGutter, @onDragGutterComplete)
            true

        true

    setData: (options) =>

        if options?
            $.extend @optionData, options, true

        @setupSplitter()
        true

    show: (name, size) =>

        @setData()
        if size?
            if Array.isArray(size)
                @optionData.size = size[0]
            else
                @optionData.size = size

        if name?
            @gid = name
        else
            @gid = GlobalValueManager.NextGlobalID()
    
        true

    setHorizontal: ()=>

        @optionData.direction = "horizontal"

        ##|
        ##| if already showing, force a resize / redraw
        if @gutter?
            @resetSize()

        return true

    getFirst: ()=>
        return @first

    getSecond: ()=>
        return @second

    getWidget: () =>
        return @gutter

