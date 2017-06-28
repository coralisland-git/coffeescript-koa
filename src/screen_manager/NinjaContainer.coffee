##|
##|  A container holds content and responds to outside events.
##|  All containers are a fixed size and absolute
##|

###

setHolder(el) - Pass in another container or jQuery element.
move(x,y,w,h)
show()
hide()
height()
width()
outerHeight()
outerWidth()
offset()

add(tagName, classes, id, attributes)
addDiv(classes, id, attributes)

getChildren() - returns an array of children where each is a NinjaContainer
setSize(w,h) - Request the element should change to a new size
onResize(w,h) - Called if this specific element has been resized

###

globalTagID = 0
globalDebugResize = !true
globalDebugMove = !true

class NinjaContainer

    constructor: ()->

        ##|
        ##|  Holds the main top of this container
        @el = null
        @element = null

        ##|
        ##|  A reference to the children added to this element
        @children = []

        ##|
        ##|  Already showing by default
        @visible = true

        ##|
        ##|  Unique ID for this container
        @gid     = globalTagID++

        ##|
        ##|  Special holder if this container contains a view
        @childView = null

        ##|
        ##|  Absolute position based tag
        @isAbsolute = false

        true

    ##|
    ##|  Sets the view to a docked view and callback with
    doSetViewWithNavbar: (viewName1, callBackWithViews)=>

        new Promise (resolve, reject)=>

            @setView "Docked", (dockView)=>
                dockView.setDockSize 50
                dockView.getFirst().setView "NavBar", (viewNavbar)=>
                    dockView.getSecond().setView viewName1, (viewNew)=>
                        if callBackWithViews? then callBackWithViews(viewNew, viewNavbar)
                        @resetSize()
                        resolve(viewNavbar)

    ##|
    ##|  Creates a splitter from the current view and calls the callback with splitter, and
    ##|  two other defined views created
    ##|
    doSplitView: (viewName1, viewName2, callBackWithViews)=>

        new Promise (resolve, reject)=>

            @setView "Splittable", (viewSplitter)=>
                viewSplitter.getFirst().setView viewName1, (viewNew1)=>
                    viewSplitter.getSecond().setView viewName2, (viewNew2)=>
                        if callBackWithViews?
                            callBackWithViews(viewSplitter, viewNew1, viewNew2)
                            @resetSize()

                        resolve(viewSplitter)

        true


    ##|
    ##|  Set the HTML to a given view namext
    ##|  Execute the callback with the view before returning if
    ##|  a callback is specified.  If the callback returns a promise
    ##|  that promise is yielded before the setView is returned.
    ##|
    ##|  if you send optionalData and the view has setData it will be called
    ##|
    setView: (viewName, viewCallback, optionalData)=>

        new Promise (resolve, reject)=>

            if typeof viewName == "object" and viewName.setView?
                ##|
                ##| viewName is actually a NinjaContainer object or something based on NinjaContainer
                ##| so we can say it's already loaded.
                @children.add(viewName)
                if viewCallback? then @viewCallback(viewName)
                return true

            doLoadView viewName
            .then (view)=>

                ##|
                ##|  The view now controls this el
                viewHolder = @addDiv "viewHolder View#{viewName}"
                viewHolder.setAbsolute()
                viewHolder.children.push view

                view.setHolder viewHolder
                view.parent = this

                if view.setData?
                    view.setData(optionalData)

                @childView = view

                # view.once "view_ready", ()=>
                $(document).ready ()=>

                    newWidth   = @getInsideWidth()
                    newHeight  = @getInsideHeight()
                    offsetTop  = 0
                    offsetLeft = 0

                    if globalDebugResize
                        console.log "NinjaContainer setView=#{viewName} ready ", newWidth, newHeight

                    view.move offsetLeft, offsetTop, newWidth, newHeight
                    @resetSize()

                    if view.onShowScreen?
                        view.onShowScreen(newWidth, newHeight)

                    if viewCallback?
                        result = viewCallback(view)
                        if result? and typeof result == "object" and result.then?
                            result.then ()=>
                                resolve(view)
                            return true

                    resolve(view)


    debugText: (txt)=>

        return

        if !@elDebug?
            @elDebug = $("<div />")
            @el.append(@elDebug)

            @elDebug.css
                position       : "absolute"
                zIndex         : 500000
                top            : 4
                left           : 4
                padding        : 4
                backgroundColor: "#efefbb"
                border         : "1px solid #300030"
                color          : "#200020"
                overflow       : "hidden"

        @elDebug.html txt
        true

    setSize: (w, h)=>
        ##|
        ##|  Called if you want this contain to change width and height without changing top/left location

        if globalDebugResize
            console.log "NinjaContainer setSize #{w}, #{h}", @el
            @debugText "s(#{w}, #{h})"

        if w != @cachedWidth or h != @cachedHeight
            @element.style.width = w + "px"
            @element.style.height = h + "px"
            @resetCached()
            @internalUpdateSizePosition("setSize #{w}, #{h}")

            if @childView
                offsetLeft = 0
                offsetTop  = 0
                @childView.move offsetLeft, offsetTop, w, h

        true

    ##|
    ##|  Call this to automatically reset your size but also tell the parent to try to reset his size
    resetSize: ()=>
        @internalUpdateSizePosition("resetSize")
        @setSize @width(), @height()
        if @parent? and parent.resetSize?
            @parent.resetSize();

        true

    ##|
    ##|  This function is called when the control has already resized and the DOM should be stable
    ##|  By default all we are doing is passing this event to the children.   This is unlikely to be
    ##|  correct because if you have more than one child they can't both be the same size as this holder
    ##|
    onResize: (w, h)=>

        if globalDebugResize
            console.log @el, "NinjaContainer onResize #{w}, #{h}"

        if w < 0 then w = 0
        if h < 0 then h = 0

        return { width: @width(), height: @height() }

    show: ()=>
        if !@el? then return this
        if @visible != true then @el.show()
        @visible = true
        this

    hide: ()=>
        if !@el? then return this
        if @visible == true then @el.hide()
        @visible = false
        this

    setScrollable: ()=>
        @element.style.overflow = "auto"

    ##|
    ##|  Make this container absolute positioned
    setAbsolute: ()=>
        if @isAbsolute == true then return true
        @isAbsolute = true

        @element.style.position = "absolute"
        @element.style.width    = "100%"
        @element.style.height   = "100%"
        @element.style.top      = 0
        @element.style.left     = 0
        @element.style.overflow = "hidden"

        @internalUpdateSizePosition("setAbsolute")
        true

    ##|
    ##|  Assign this container to be held by another container and thus
    ##|  it will receive events from that parent container and it will take over
    ##|  controller it's el variable or jQuery variable
    setHolder: (elHolder)=>

        if typeof elHolder == "object" and elHolder.setHolder?
            ##|
            ##|  Passing in another container
            @el = elHolder.el

        else

            @el = $(elHolder)

        @element = @el[0]
        @resetCached()

        true

    ##|
    ##|  Returns the position of the container
    ##|  { top, left } - https://api.jquery.com/position/
    position: ()=>
        if !@el? then return { top: 0, left: 0 }
        if @cachedPosition? then return @cachedPosition
        @cachedPosition = @el.position()
        return @cachedPosition

    ##|
    ##|  Reposition aboslute elements
    move: (x, y, w, h)=>

        updateNeeded = false

        if !@isAbsolute
            @setAbsolute()
            updateNeeded = true

        if globalDebugMove
            console.log @element, "NinjaContainer move (#{x}, #{y}, #{w}, #{h})"

        @debugText "m(#{x}, #{y}, #{w}, #{h})"

        if x != @x
            @x = x
            @element.style.left = @x + "px"
            updateNeeded = true

        if y != @y
            @y = y
            @element.style.top = @y + "px"
            updateNeeded = true

        if w != @cachedWidth or h != @cachedHeight
            @setSize w, h
            updateNeeded = true

        if updateNeeded
            @internalUpdateSizePosition("move #{x} vs #{@x}, #{y} vs #{@y}, #{w} vs #{@cachedWidth}, #{h} vs #{@cachedHeight}")

        return updateNeeded

    ##|
    ##|  Returns the height
    getHeight: ()=>
        if @cachedHeight? then return @cachedHeight
        if !@el? then return 0

        if @isAbsolute
            @cachedHeight = @el.outerHeight()
        else
            @cachedHeight = @el.height()

        return @cachedHeight

    ##|
    ##|  Possible badge text for views that support it
    ##|  check all children to see if one does
    getBadgeText: ()=>

        # console.log this, "getBadgeText()", @children

        for c in @children
            if c.getBadgeText?
                testText = c.getBadgeText()
                if testText? then return testText

        return null

    ##|
    ##|  Set the height
    setHeight: (h)=>
        if h == @cachedHeight then return h
        @internalUpdateSizePosition("setHeight #{h} vs #{@cachedHeight}")
        @cachedHeight = h
        if @isAbsolute
            @el.outerHeight(h)
        else
            @el.height(h)

        return h

    height: (h)=>
        if h? then @setHeight(h); else @getHeight()

    setMinHeight: (newMin)=>
        @minHeight = newMin
        if @childView? and @childView.setMinHeight? then @childView.setMinHeight(newMin)
        @resetSize()
        return @minHeight

    setMaxHeight: (newMax)=>
        @maxHeight = newMax
        if @childView? and @childView.setMaxHeight? then @childView.setMaxHeight(newMin)
        @resetSize()
        return @maxHeight

    getMinHeight: ()=>
        if @minHeight? then return @minHeight
        if @childView? and @childView.getMinHeight? then return @childView.getMinHeight()
        return null

    getMaxHeight: ()=>
        if @maxHeight? then return @maxHeight
        if @childView? and @childView.getMaxHeight? then return @childView.getMaxHeight()
        return null

    getInsideWidth: ()=>
        if @cachedInsideWidth? then return @cachedInsideWidth
        @cachedInsideWidth = @el.width()
        return @cachedInsideWidth

    getInsideHeight: ()=>
        if @cachedInsideHeight? then return @cachedInsideHeight
        @cachedInsideHeight = @el.height()
        return @cachedInsideHeight


    ##|
    ##|  Get the current width
    getWidth: ()=>
        if @cachedWidth? then return @cachedWidth
        if !@el? then return 0

        if @isAbsolute?
            @cachedWidth = @el.outerWidth()
        else
            @cachedWidth = @el.width()

        return @cachedWidth

    ##|
    ##|  set the current width
    setWidth: (w)=>
        if w == @cachedWidth then return w
        @internalUpdateSizePosition("setWidth #{w} vs #{@cachedWidth}")
        @cachedWidth = w

        if @isAbsolute
            @el.outerWidth(w)
        else
            @el.width(w)

        return w

    width: (w)=>
        if w? then @setWidth(w); else @getWidth(w)

    setMinWidth: (newMin)=>
        if newMin == @minWidth then return @minWidth
        @minWidth = newMin
        if @childView? and @childView.setMinWidth? then @childView.setMinWidth(newMin)
        @resetSize()
        return @minWidth

    setMaxWidth: (newMax)=>
        if @maxWidth == newMax then return @maxWidth
        @maxWidth = newMax
        if @childView? and @childView.setMaxWidth? then @childView.setMaxWidth(newMin)
        return @maxWidth

    getMinWidth: ()=>
        if @minWidth? then return @minWidth
        if @childView? and @childView.getMinWidth? then return @childView.getMinWidth()
        return null

    getMaxWidth: ()=>
        if @maxWidth? then return @maxWidth
        if @childView? and @childView.getMaxWidth? then return @childView.getMaxWidth()
        @resetSize()
        return null

    ##|
    ##| Return outer width
    outerWidth: ()=>
        if @cachedOuterWidth? then return @cachedOuterWidth
        if !@el? then return 0
        @cachedOuterWidth = @el.outerWidth()
        return @cachedOuterWidth

    ##|
    ##| return outer height
    outerHeight: ()=>
        if @cachedOuterHeight? then return @cachedOuterHeight
        if !@el? then return 0
        @cachedOuterHeight = @el.outerHeight()
        return @cachedOuterHeight

    scrollTop: ()=>
        if @element? then return @element.scrollTop
        return 0

    offsetTop: ()=>
        if @element? then return @element.offsetTop
        if @el? then return @el.offset().top
        return 0

    offset: ()=>
        if @cachedOffset then return @cachedOffset
        if !@el? then return { top: 0, left: 0 }
        @cachedOffset = @el.offset()
        return @cachedOffset

    ##|
    ##|  Give the element a new zindex value
    ##|  Can be any of number, auto, initial, inherit
    ##|  see http://www.w3schools.com/jsref/prop_style_zindex.asp
    setZ: (newZIndex = "auto")=>
        @element.style.zIndex = newZIndex

    getZ: ()=>
        return @element.style.zIndex

    getChildren: () =>
        return @children

    ##|
    ##|  Adds a new child tag under this one of a given type
    ##|  with a default class, id, and attributes
    ##|
    add: (tagName, classes, id, attributes) =>
        tag = new WidgetTag tagName, classes, id, attributes
        tag.parent = this
        @el.append tag.el
        @children.push tag
        return tag

    ##|
    ##|  Add the element but do it within the certain order
    addAtPosition: (tagName, classes, position) =>

        tag = new WidgetTag tagName, classes
        tag.parent = this

        count = 0
        for child in @children
            if position == count
                console.log "insertBefore ", child.el
                tag.el.insertBefore(child.el)
                @children.splice count, 0, tag
                return tag

            count++

        @el.append tag.el
        @children.push tag
        return tag

    ##|
    ##|  Shortcut to add a div
    addDiv: (classes, id, attributes) =>
        return @add "div", classes, id

    ##|
    ##|  Internal helper function that should be called if any function
    ##|  knowingly changes the size or position
    ##|
    internalUpdateSizePosition : (txtDebug)=>
        if globalDebugResize
            @iusp = (@iusp || 0) + 1
            console.log @element, "NinjaContainer internalUpdateSizePosition #{@iusp} - #{txtDebug}"

        @resetCached()

        if @internalUpdateTimer? then clearTimeout(@internalUpdateTimer)
        @internalUpdateTimer = setTimeout ()=>

            @cachedHeight      = @getHeight()
            @cachedWidth       = @getWidth()
            @cachedOuterHeight = @outerHeight()
            @cachedOuterWidth  = @outerWidth()
            @cachedOffset      = @el.offset()
            @cachedPosition    = @el.position()

            if @cachedPosition? and @cachedPosition.top?
                @x = @cachedPosition.left
                @y = @cachedPosition.top
            else
                @x = 0
                @y = 0

            @onResize(@cachedOuterWidth, @cachedOuterHeight)

        , 10

        true

    ##|
    ##|  Clear internally cached values
    ##|
    resetCached: ()=>
        delete @cachedInsideWidth
        delete @cachedInsideHeight
        delete @cachedHeight
        delete @cachedWidth
        delete @cachedOuterHeight
        delete @cachedOuterWidth
        delete @cachedOffset
        delete @cachedPosition
        delete @x
        delete @y

        true