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
        if @wdtSplittable?
            @wdtSplittable.setSize(w, h)
        true

    getDependencyList: () =>
        return ["/vendor/split.min.js"]

    setData: (@optionData) =>

    show: (name) =>
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

