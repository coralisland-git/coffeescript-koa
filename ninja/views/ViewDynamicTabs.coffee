
class ViewDynamicTabs extends View

    onResize: (w, h)=>

        @currentSizeW = w
        @currentSizeH = h
        console.log "ViewDynamicTabs onResize #{w}, #{h}", @elHolder
        if @tabs? then @tabs.onResize(w, h)
        true

    onShowScreen: ()=>

        console.log "ViewDynamicTabs onShowScreen"
        @tabs = new DynamicTabs @elHolder
        if @currentSizeW? and @currentSizeH? and @currentSizeW > 0
            @tabs.onResize(@currentSizeW, @currentSizeH)

        true