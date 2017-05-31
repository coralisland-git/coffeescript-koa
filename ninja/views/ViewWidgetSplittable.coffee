##|
##| Based on https://github.com/nathancahill/Split.js/

class ViewWidgetSplittable extends View
    ##
    ## default function of class View that is necessary
    ##
    onSetupButtons: () =>

    ##
    ## default function of class View
    ##
    setTitle: (title)=>
        return

    onResize: (w, h)=>
        ##|
        ##|  Parent container has changed size.  The parent is now w x h
        if @wdtSplittable?
            @wdtSplittable.setSize(w, h)
        true

    setSize: (w, h)=>
        if @elHolder?
            @elHolder.width w
            @elHolder.height h
        true

    getDependencyList: () =>
        return ["/vendor/split.min.js"]

    setData: (options) =>

        if !@optionData?
            @optionData = {}

        if options?
            $.extend @optionData, options, true

        if !@optionData.sizes?
            @optionData.sizes = [ 50, 50 ]

        if !@optionData.direction?
            @optionData.direction = "vertical"

        if !@optionData.gutterSize?
            @optionData.gutterSize = 6

        if !@optionData.gutterSize?
            @optionData.gutterSize = 6

        if !@optionData.cursor?
            @optionData.cursor = "row-resize"

        if !@optionData.minSize?
            @optionData.minSize = 10

        true

    show: (name, sizes) =>

        @setData()
        if sizes?
            @optionData.sizes = sizes

        if name?
            @gid = name
        else
            @gid = GlobalValueManager.NextGlobalID()
    
        @elHolder.find(".widgetsplittable-container").attr "id","widgetsplittable#{@gid}"
        @wdtSplittable = new WidgetSplittable @elHolder.find("#widgetsplittable#{@gid}")
        @wdtSplittable.render(@optionData)

        @elHolder.onResize = (w, h)=>
            console.log "ViewWidgetSplittable elHolder.onResize(#{w}, #{h})"
            true

        @wdtSplittable.onResize = (w, h)=>
            console.log "wdtSplittable onResize(#{w}, #{h})"
            true

        true

    getWidget: () =>
        return @wdtSplittable

