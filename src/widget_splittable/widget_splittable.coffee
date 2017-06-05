class WidgetSplittable

    validProperties: ["sizes", "minSize", "direction", "gutterSize"
                    "snapOffset", "cursor", "elementStyle", "gutterStyle"
                    "onDrag", "onDragStart", "onDragEnd"]
    validDirections: ["horizontal", "vertical"]

    constructor: (@elementHolder) ->
        @splitData = {}
        @gid = GlobalValueManager.NextGlobalID()
        true

    getSizes: ()=>
        return @splitInstance.getSizes()

    ##|
    ##|  Default event if the splitter changes sizes
    onDefaultDragEnd: ()=>
        w = @elementHolder.width()
        h = @elementHolder.height()
        s = @getSizes()
        @setSize(w, h)
        console.log "WidgetSplittable onDefaultDragEnd w=", w, "h=", h, "s=", s
        true

    setSize: (w, h)=>
        # console.log "WidgetSplittable setSize(#{w}, #{h})"

        if w > 0
            @elementHolder.width(w)
        if h > 0
            @elementHolder.height(h)

        sizes = @getSizes()
        # console.log "WidgetSplittable onResize(#{w}, #{h})", sizes

        first       = @getFirstChild()
        second      = @getSecondChild()

        allSpacingH = 2
        allSpacingW = 2

        # console.log "WidgetSplittable setSize, allSpacing=#{allSpacingW},#{allSpacingH} for first=", first.el, "second=", second.el

        ##|
        ##|  6px for the splitter
        if @splitData.direction == "vertical"
            y1 = Math.floor(h * (sizes[0]/100)) - allSpacingH - 3
            y2 = Math.floor(h * (sizes[1]/100)) - allSpacingH - 3
            # console.log "WidgetSplittable new sizes y1=#{y1} y2=#{y2} w=#{w}-#{allSpacingW}"
            if first.onResize? then first.onResize(w - allSpacingW, y1)
            if second.onResize? then second.onResize(w - allSpacingW, y2)
        else
            x1 = Math.floor(w * (sizes[0]/100)) - 3
            x2 = w - x1 - 3
            # console.log "WidgetSplittable new sizes x1=#{x1} x2=#{x2}"
            if first.onResize? then first.onResize(x1, h - allSpacingH)
            if second.onResize? then second.onResize(x2, h - allSpacingH)

        true

    setData: (data) =>
        if !@checkValidData data then return false

        if !data.onDragEnd?
            data.onDragEnd = @onDefaultDragEnd

        for prop in @validProperties
            @splitData[prop] = data[prop]

        @element1 = new WidgetTag "div", "split", "split_1#{@gid}"
        @element1.appendTo @elementHolder

        @element2 = new WidgetTag "div", "split", "split_2#{@gid}"
        @element2.appendTo @elementHolder

        return true
        
    checkValidData: (data) =>
        if !window.Split
            console.log "Error: Plugin Split not loaded"
            
        if @validDirections.indexOf(data.direction) is -1
            return false 

        true

    render: (data) =>
        if !@setData(data) then return false
        direction = @splitData.direction
        @element1.addClass "split-#{direction}"
        @element2.addClass "split-#{direction}"
        @splitInstance = Split ["##{@element1.id}", "##{@element2.id}"], @splitData
        true

    getFirstChild: () =>
        return @element1

    getSecondChild: () =>
        return @element2 

