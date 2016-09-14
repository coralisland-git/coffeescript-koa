globalMouseDrag = null

class GlobalMouseDrag

    onMouseMove: (e)=>

        diffX = e.pageX - @globalDragStartX
        diffY = e.pageY - @globalDragStartY
        # console.log "dragMove #{diffX}, #{diffY}"
        if @onChange? then @onChange(diffX, diffY, e)
        return false

    onMouseUp: (e)=>

        diffX = e.pageX - @globalDragStartX
        diffY = e.pageY - @globalDragStartY
        # console.log "onMouseUp #{diffX}, #{diffY}"
        if @onFinished? then @onFinished(diffX, diffY, e)
        globalMouseDrag.document.off "mousemove touchmove pointermove", globalMouseDrag.onMouseMove
        $(globalMouseDrag.target).removeClass "dragging"

        delete globalMouseDrag.target
        delete globalMouseDrag.onChange
        delete globalMouseDrag.onFinished

        return false

    @startDrag: (e, dragMove, dragFinished)=>

        if globalMouseDrag == null
            globalMouseDrag = new GlobalMouseDrag()
            globalMouseDrag.document = $(document)

        globalMouseDrag.target           = e.target
        globalMouseDrag.globalDragStartX = e.pageX
        globalMouseDrag.globalDragStartY = e.pageY
        globalMouseDrag.onChange         = dragMove
        globalMouseDrag.onFinished       = dragFinished

        globalMouseDrag.document.on "mousemove touchmove pointermove", globalMouseDrag.onMouseMove
        globalMouseDrag.document.one "mouseup touchend pointerup", globalMouseDrag.onMouseUp

        $(e.target).addClass "dragging"
        return false