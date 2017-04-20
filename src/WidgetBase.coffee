globalTagData = {}
globalTagPath = {}
globalTagID   = 0

class WidgetTag

    ##|
    ##|  Properties
    ##|  el  - DOM elemenet
    ##|  id  - optional id
    ##|  classes - optional array of classes
    ##|  parent -  pointer to another WidgetTag
    ##|

    @getDataFromEvent: (e)->

        if !e? or !e.target? then return {}

        results = {}
        results.coords = GlobalValueManager.GetCoordsFromEvent(e)

        ##|
        ##|  Recursive loop through the element and then all the parents
        ##|  looking for the data-id value and pulling in data from those
        ##|  elements,  the top level element data is loaded first so
        ##|  the deeper into the DOM the data over-writes.
        ##|
        getFromElement = (results, target, level)->

            if target.parentElement? and level < 6
                getFromElement(results, target.parentElement, level + 1)

            for varName, value of target.dataset
                if varName == "id" then continue
                results[varName] = value

            id = target.dataset.id
            if id? and typeof id == "string"
                id = parseInt(id)

            if id? and typeof id == "number"
                if globalTagData[id]?
                    for varName, value of globalTagData[id]
                        results[varName] = value


        getFromElement(results, e.target, 0)
        return results

    constructor: (tagName, classes, id, attributes)->

        ##|
        ##|  Store a reference to the jQuery version and the raw html5 element
        @el      = $(document.createElement tagName)
        @element = @el[0]
        @gid     = globalTagID++

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
        ##|  Absolute positioned element @see setAbsolute()
        @isAbsolute = false

        ##|
        ##|  All tags have an id number referenced into the globalTagData
        @element.dataset.id = @gid

        ##|
        ##|  Any other attributes that need setting
        if attributes?
            for attName, attValue of attributes
                @el.attr attName, attValue

    ##|
    ##| Returns @el of WidgetTag Instance
    ##|
    getTag: () =>
        return @el

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

    getChildren: () =>
        return @children
    ##|
    ##|  Shortcut to add a div
    addDiv: (classes, id, attributes) =>
        return @add "div", classes, id

    resetDataValues: ()=>
        if globalTagData[@gid]?
            path = globalTagData[@gid]
            if path? then delete globalTagPath[path]
            globalTagData[@gid] = {}

        for c in @children
            c.resetDataValues()

        return true

    ##|
    ##|  Shortcut to setting a data value for the path
    setDataPath: (keyVal) =>
        globalTagPath[keyVal] = @gid
        @setDataValue "path", keyVal

    ##|
    ##|  Set the "data-" values within the element, cache
    ##|  then and only update the DOM if there is a change
    setDataValue: (name, value)=>
        if !globalTagData[@gid]
            globalTagData[@gid] = {}

        globalTagData[@gid][name] = value
        return this

    ##|
    ##|  Use the cache to get any elements
    getDataValue: (name) =>
        if !globalTagData[@gid]
            globalTagData[@gid] = {}

        return globalTagData[@gid][name]

    ##|
    ##|  Give the element a new zindex value
    ##|  Can be any of number, auto, initial, inherit
    ##|  see http://www.w3schools.com/jsref/prop_style_zindex.asp
    setZ: (newZIndex = "auto")=>
        if !@isAbsolute? or @isAbsolute != true
            console.log "Warning: WidgetBase setting z index without absolute position"

        @element.style.zIndex = newZIndex

    getZ: ()=>
        return @element.style.zIndex

    ##|
    ##|  Add the "absolute" style to an element
    ##|  you can also specify something else such as inline, relative, etc
    ##|
    setAbsolute: (newIsAbsolute = true)=>
        if newIsAbsolute == @isAbsolute then return
        if newIsAbsolute
            @element.style.position = "absolute"
        else
            @element.style.position = newIsAbsolute

        @isAbsolute = newIsAbsolute
        true

    ##|
    ##|  Set an attribute
    setAttribute: (keyName, keyVal) =>
        @el.attr keyName, keyVal
        return this

    ##|
    ##|  Toggle a CSS class either on off as needed
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

    resetClasses: (newListText) =>
        @classes = newListText.split(" ")
        @element.className = @classes.join ' '

    ##|
    ##|  Add an enable a class name
    addClass: (className) =>
        for cn in @classes
            if cn == className then return true

        ##|
        ##| TODO: check the @classes list and cache
        @classes.push className
        @element.className = @classes.join ' '
        return true

    ##|
    ##|  Remove a class
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

        return true

    height: ()=>
        if @cachedHeight? then return @cachedHeight
        @cachedHeight = @el.height()
        return @cachedHeight

    width: ()=>
        if @cachedWidth? then return @cachedWidth
        @cachedWidth = @el.width()
        return @cachedWidth

    outerWidth: ()=>
        return @el.outerWidth()

    outerHeight: ()=>
        return @el.outerHeight()

    offset: ()=>
        return @el.offset()

    ##|
    ##|  Append this widget element to a jquery element
    appendTo: (jqueryElement)=>
        $(jqueryElement).append @el

    append: (html)=>
        ##|
        ##|  Shouldn't really be used, add should be used instead
        console.log "Warning: WidgetTag append called adding ", html
        @el.append $(html)

    ##|
    ##|  Call this function if the outside container changes size
    onResize: ()=>
        delete @cachedWidth
        delete @cachedHeight
        for c in @children
            c.onResize()

        if @view?
            console.log "Resizing widget view to ", @width(), @height()
            @view.onResize(@width(), @height())

        true

    ##|
    ##|   Set the text value or get the text value if nothing passed in
    text: (str) =>
        if !str? then return !currentValue

        if @currentValue != str
            @currentValue = str
            @element.innerText = str

        return this

    ##|
    ##|  Set or get the current html value
    html: (str) =>

        if !str? then return @currentValue

        if @currentValue != str
            @currentValue = str
            if /</.test str
                @element.innerHTML = str
            else
                @element.innerText = str

        return this

    ##|
    ##|  Get the value (for input style elements)
    ##|
    val: (str) =>
        if !str?
            @currentValue = @el.val()
            return @currentValue

        if @currentValue != str
            @currentValue = str
            @el.val(str)

        return this

    show: ()=>
        if @visible != true then @el.show()
        @visible = true
        this

    hide: ()=>
        if @visible == true then @el.hide()
        @visible = false
        this

    ##|
    ##|  Reposition aboslute elements
    move: (x, y, w, h)=>

        if x != @x
            @x = x
            @element.style.left   = @x + "px"

        if y != @y
            @y = y
            @element.style.top    = @y + "px"

        if w != @w
            @w = w
            delete @cachedWidth
            @element.style.width  = @w + "px"

        if h != @h
            @h = h
            delete @cachedHeight
            @element.style.height = @h + "px"

        return this

    position: ()=>
        pos = @el.position()
        return pos

    find: (str)=>
        return @el.find(str)

    on: (eventName, callback)=>
        @bind(eventName, callback)

    ##|
    ##|  Set the HTML to a given view name
    ##|  Execute the callback with the view before returning if
    ##|  a callback is specified
    setView: (viewName, viewCallback)=>

        new Promise (resolve, reject)=>

            doAppendView viewName, @el
            .then (view)=>
                if viewCallback?
                    viewCallback(view)

                @view = view
                @onResize()

                resolve(view)

    ##|
    ##|  Bind helper function, does a jQuery bind but first
    ##|  sets the path and other data elements before calling
    ##|  the target callback function.
    ##|
    bind: (eventName, callback)=>
        ##|
        ##|  For mouse events, add a reference to the callback
        ##|  so the event handled can easily find this ID
        @el.unbind eventName
        @el.bind eventName, (e)->

            data = WidgetTag.getDataFromEvent(e)
            #console.log "bind DataFromEvent:", data
            for varName, value of data
                e[varName] = value

            if callback(e)
                e.preventDefault()
                e.stopPropagation()
                return true

            return false

        return this
    ##|    
    ##| New function added by tkooistra
    ##| Render filed of table appointed by table/id/filed
    ##|
    renderField: (tableName, idValue, fieldName) =>
        if !tableName? then return @el        
        dm = DataMap.getDataMap()
        path = "/#{tableName}/#{idValue}/#{fieldName}"
        currentValue = DataMap.getDataFieldFormatted tableName, idValue, fieldName

        ## Add class `data` as a default one for widget binded to a table field    
        classes = ["data"]

        if dm.types[tableName]?.col[fieldName]?.getEditable() == true
            @bind 'click', globalOpenEditor
            classes.push "editable"
        @addClass className for className in classes
        @setAttribute 'data-path', path
        @html currentValue
        
        return @el

    ##| 
    ##| New function added by tkooistra
    ##| Bind a path(table/id/field) to a WidgetTag
    ##| so that the WidgetTag can know and automatically update itself
    ##| when there is any modification in data of the field in table
    ##|

    bindToPath: (tableName, idValue, fieldName) =>
        dm = DataMap.getDataMap()
        @renderField tableName, idValue, fieldName
        path = "/#{tableName}/#{idValue}/#{fieldName}"
        
        dm.on( "new_data"
            , (table, id) =>
                if table is tableName and id is idValue
                    #console.log("Event emitted by DataMap: #{table}/#{id}")
                    @renderField tableName, idValue, fieldName
            )
        globalKeyboardEvents.on( "change"
            , (pathChanged, newValue) =>
                if pathChanged is path
                    @renderField tableName, idValue, fieldName
            )
        true
        
        

    ##|  Destroy an element, remove all children and destroy them.
    ##|  Remove global variables and cleanup the DOM after.
    ##|  Sends a resize message globally.
    ##|
    destroy: ()=>
        ##|
        ##|  remove this element and remove it from the DOM
        if !@el? then return

        for c in @children
            c.destroy()

        delete globalTagData @gid
        delete globalTagPath @gid
        @el.remove()
        delete @el
        delete @children
        for varName, value of this
            console.log "destroy #{@gid} var=#{varName}, value=", value

        return true

class WidgetBase extends WidgetTag

    constructor: ()->

        if !document?
            console.log "INVALID CALL: Document not ready"

        @children = []
        @el = $(document.createDocumentFragment())
