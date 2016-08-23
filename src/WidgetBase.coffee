class WidgetTag

    ##|
    ##|  Properties
    ##|  el  - DOM elemenet
    ##|  id  - optional id
    ##|  classes - optional array of classes
    ##|  parent -  pointer to another WidgetTag
    ##|

    constructor: (tagName, classes, id, attributes)->

        ##|
        ##|  Store a reference to the jQuery version and the raw html5 element
        @el      = $(document.createElement tagName)
        @element = @el[0]

        if id?
            @el.attr "id", id
            @id = id

        ##|
        ##|  Classes stores a list of active classes on the element
        if classes?
            @el.attr "class", classes
            @classes = classes.split ' '
        else
            @classes = []

        ##|
        ##|  A reference to the children added to this element
        @children = []

        ##|
        ##|  Already showing by default
        @visible = true

        ##|
        ##|  Any other attributes that need setting
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

    ##|
    ##|  Set the "data-" values within the element, cache
    ##|  then and only update the DOM if there is a change
    setDataValue: (name, value)=>
        if !@dataValues? then @dataValues = {}
        if @dataValues[name] != value
            @dataValues[name] = value
            @element.dataset[name] = value

        return this

    ##|
    ##|  Use the cache to get any elements
    getDataValue: (name) =>
        if !@dataValues? then @dataValues = {}
        return @dataValues[name]

    ##|
    ##|  Add the "absolute" style to an element
    setAbsolute: ()=>
        @element.style.position = "absolute"
        true

    ##|
    ##|  Set an attribute
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

        newList        = []
        foundValid     = false
        foundInvalid   = false
        updateRequired = false

        for name in @classes
            if validClass == name
                foundValid = true
                newList.push validClass
            else if patternForGroup.test name
                foundInvalid = true
            else
                newList.push name

        if foundInvalid
            @classes = newList
            updateRequired = true

        if !foundValid and validClass != null
            @classes.push validClass
            updateRequired = true

        if updateRequired
            @element.className = @classes.join ' '

        true

    addClass: (className) =>
        for cn in @classes
            if cn == className then return true

        ##|
        ##| TODO: check the @classes list and cache
        @classes.push className
        @element.className = @classes.join ' '
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
            @element.className = @classes.join ' '

        return this

    height: ()=>
        return @el.height()

    width: ()=>
        return @el.width()

    text: (str) =>
        if @currentValue != str
            @currentValue = str
            @element.innerText = str

        return this

    val: (str) =>
        if @currentValue != str
            @currentValue = str
            @el.val(str)

        return this

    html: (str) =>

        if @currentValue != str
            @currentValue = str
            @element.innerHTML = str

        return this

    show: ()=>
        if @visible != true then @el.show()
        @visible = true
        this

    hide: ()=>
        if @visible == true then @el.hide()
        @visible = false
        this

    move: (x, y, w, h)=>

        if x != @x
            @x = x
            @element.style.left   = @x + "px"

        if y != @y
            @y = y
            @element.style.top    = @y + "px"

        if w != @w
            @w = w
            @element.style.width  = @w + "px"

        if h != @h
            @h = h
            @element.style.height = @h + "px"

        return this

    on: (eventName, callback)=>
        @bind(eventName, callback)

    bind: (eventName, callback)=>
        ##|
        ##|  For mouse events, add a reference to the callback
        ##|  so the event handled can easily find this ID
        @el.bind eventName, (e)=>

            allData = e.target.parentElement.parentElement.dataset
            for keyName, keyVal of allData
                e[keyName] = keyVal

            allData = e.target.parentElement.dataset
            for keyName, keyVal of allData
                e[keyName] = keyVal

            allData = e.target.dataset
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
