class WidgetTag

    ##|
    ##|  Properties
    ##|  el  - DOM elemenet
    ##|  id  - optional id
    ##|  classes - optional array of classes
    ##|  parent -  pointer to another WidgetTag
    ##|

    constructor: (tagName, classes, id, attributes)->

        @el = $(document.createElement tagName)

        if id?
            @el.attr "id", id
            @id = id

        if classes?
            @el.attr "class", classes
            @classes = classes.split ' '

        if attributes?
            for attName, attValue of attributes
                @el.attr attName, attValue

    add: (tagName, classes, id, attributes) =>
        tag = new WidgetTag tagName, classes, id, attributes
        tag.parent = this
        @el.append tag.el
        return tag

    addDiv: (classes, id, attributes) =>
        return @add "div", classes, id

    setDataPath: (keyVal) =>
        @el.attr "data-path", keyVal
        return this

    setAttribute: (keyName, keyVal) =>
        @el.attr keyName, keyVal
        return this

    addClass: (className) =>
        for cn in @classes
            if cn == className then return this

        ##|
        ##| TODO: check the @classes list and cache
        @classes.push className
        @el.addClass className
        return this

    removeClass: (className) =>

        newList = []
        found   = false
        for cn in @classes
            if cn == className
                found = true
            else
                newList.push cn

        @classes = newList

        ##|
        ##| TODO: check the @classes list and cache
        @el.removeClass className

        return this

    text: (str) =>
        if @currentValue != str
            @currentValue = str
            @el.text(str)

        return this

    val: (str) =>
        if @currentValue != str
            @currentValue = str
            @el.val(str)

        return this

    html: (str) =>

        if @currentValue != str
            @currentValue = str
            @el.html(str)

        return this

    show: ()=>
        @el.show()
        this

    hide: ()=>
        @el.hide()
        this

    move: (x, y, w, h)=>
        if x != @x or y != @y or w != @w or h != @h
            @x = x
            @y = y
            @w = w
            @h = h
            @el[0].style.left   = @x + "px"
            @el[0].style.top    = @y + "px"
            @el[0].style.width  = @w + "px"
            @el[0].style.height = @h + "px"

            # @el.css
            #     left   : @x
            #     top    : @y
            #     width  : @w
            #     height : @h

        return this

    bind: (eventName, callback)=>
        ##|
        ##|  For mouse events, add a reference to the callback
        ##|  so the event handled can easily find this ID
        @el.bind eventName, (e)=>

            path = $(e.target).data("path")
            if !path? or !path
                path = $(e.target).parent().data("path")

            e.path = path

            if callback(e)
                e.preventDefault()
                e.stopPropagation()
                return true

            return false

        return this


class WidgetBase extends WidgetTag

    constructor: ()->

        if !document?
            console.log "INVALID CALL: Document not ready"

        @el = $(document.createDocumentFragment())

