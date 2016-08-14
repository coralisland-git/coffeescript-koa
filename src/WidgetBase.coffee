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
        else
            @classes = []

        @children = []

        if attributes?
            for attName, attValue of attributes
                @el.attr attName, attValue

    add: (tagName, classes, id, attributes) =>
        tag = new WidgetTag tagName, classes, id, attributes
        tag.parent = this
        @el.append tag.el
        @children.push tag
        return tag

    addDiv: (classes, id, attributes) =>
        return @add "div", classes, id

    setDataPath: (keyVal) =>
        @setDataValue "path", keyVal

    setDataValue: (name, value)=>
        if !@dataValues? then @dataValues = {}
        if @dataValues[name] != value
            @dataValues[name] = value
            @el[0].dataset[name] = value
            # @el.attr "data-#{name}", value

        return this

    getDataValue: (name) =>
        if !@dataValues? then @dataValues = {}
        return @dataValues[name]

    setAbsolute: ()=>
        @el.css "position", "absolute"
        true

    setAttribute: (keyName, keyVal) =>
        @el.attr keyName, keyVal
        return this

    ##|
    ##|  Toggle a CSS class either on off as needed
    ##|
    setClass: (className, enabled)=>

        if enabled == true
            return @addClass(className)
        else
            return @removeClass(className)

    ##|
    ##|  Make sure only one of a given type of class is enabled
    setClassOne: (validClass, patternForGroup)=>

        if typeof patternForGroup == "string"
            patternForGroup = new RegExp patternForGroup

        newList      = []
        foundValid   = false
        foundInvalid = false

        for name in @classes
            if validClass == name
                foundValid = true
                newList.push validClass
            else if patternForGroup.test name
                foundInvalid = true
            else
                newList.push name

        @classes = newList
        if !foundValid then @classes.push validClass

        if foundInvalid or !foundValid
            @el[0].className = @classes.join ' '

        true

    addClass: (className) =>
        for cn in @classes
            if cn == className then return true

        ##|
        ##| TODO: check the @classes list and cache
        @classes.push className
        @el[0].className = @classes.join ' '
        return this

    removeClass: (className) =>

        newList = []
        found   = false
        for cn in @classes
            if cn == className
                found = true
            else
                newList.push cn

        if found
            @classes = newList
            @el[0].className = @classes.join ' '

        return this

    height: ()=>
        return @el.height()

    width: ()=>
        return @el.width()

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

        if x != @x
            @x = x
            @el[0].style.left   = @x + "px"

        if y != @y
            @y = y
            @el[0].style.top    = @y + "px"

        if w != @w
            @w = w
            @el[0].style.width  = @w + "px"

        if h != @h
            @h = h
            @el[0].style.height = @h + "px"

        return this

    bind: (eventName, callback)=>
        ##|
        ##|  For mouse events, add a reference to the callback
        ##|  so the event handled can easily find this ID
        @el.bind eventName, (e)=>

            allData = $(e.target).parent().parent().data()
            for keyName, keyVal of allData
                e[keyName] = keyVal

            allData = $(e.target).parent().data()
            for keyName, keyVal of allData
                e[keyName] = keyVal

            allData = $(e.target).data()
            for keyName, keyVal of allData
                e[keyName] = keyVal

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

        @children = []
        @el = $(document.createDocumentFragment())
