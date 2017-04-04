reDate2           = /[0-9\-]+T[0-9\:\.]+Z$/
checkForNumber    = /^[1-9\-][\d\-\.]{0,11}$/

##| -------------------------------------------------------------------------------------------------------------
##|
##| This class is a basic memory map that stores data for a collection in an array
##| then you can get data out using some key comparison, usually "id" values
##| for a fast lookup.
##|
class DataMapMemoryCollection

    ##|
    ##|  In memory storage for a simple table
    ##|

    constructor: (@name, @index) ->

        @data  = {}
        @count = 0

    ##|
    ##|  Export the entire collection
    export: ()=>
        return @data

    ##|
    ##|  Look at all documents and find the one that filter
    ##|  filter returns TRUE to keep the record, false to skip it
    ##|
    findAll: (filterFunction) =>

        allResults = []
        for key, obj of @data
            if filterFunction?
                result = filterFunction(obj)
            else
                result = true

            if result
                allResults.push obj

        return allResults

    ##|
    ##|  Search for a condition
    ##|  current support is an array of possible values
    ##|  Example: { id: 10 }

    find: (condition) =>

        if !@index? and condition? and condition.id? and Object.keys(condition).length == 1

            ##|
            ##| Fast search by id
            if !@data[condition.id]?
                return null

            # doc = $.extend(true, {}, @data[condition.id])
            return @data[condition.id]

        else

            # console.log "find: (", condition, "):"

            ##|
            ##| Complex search
            allResult = []
            for key, obj of @data
                found = false
                for i, o of condition
                    if obj[i] != o then found = false
                if found
                    allResult.push o

            return allResult

    setFast: (idValue, subKey, newValue)=>

        if idValue? and @data[idValue]?
            @data[idValue][subKey] = newValue

        return

    ##|
    ##|  Find a single record for read-online
    findFast: (idValue, subKey) =>

        if idValue? and @data[idValue]?
            return @data[idValue][subKey]
        else
            return null

    ##|
    ##|  Find a single record for read-online
    findFastRow: (idValue) =>

        if idValue? and @data[idValue]?
            return @data[idValue]
        else
            return null

    ##|
    ##|  Fully update the document in memory
    ##|

    upsert: (doc) =>
        strKey = @getDocumentKey(doc)
        isKeyNew = @data[strKey]?
        # console.log "upsert #{strKey}:", doc
        @data[strKey] = doc
        if isKeyNew then @count++
        return @data[strKey]

    ##|
    ##|  Remove a key
    remove: (condition) =>

        allResults = @find condition
        if !allResults? then return false
        if allResults? and allResults[0]?
            for i, obj of allResults
                strKey = @getDocumentKey[obj]
                delete @data[strKey]
        else
            delete @data[@getDocumentKey allResults]

        return true

    ##|
    ##|  Internal function to convert a document to it's key
    ##|  depending on the indexes available
    getDocumentKey: (doc) =>

        if !@index? then return doc.id

        strKey = ""
        for keyName in @index
            if !doc[keyName]?
                doc[keyName] = @count++
            strKey += doc[keyName] + "-"

        return strKey

    ##|
    ##|  Erase the data from the colleciton
    eraseCollection: ()=>

        @data  = {}
        @count = 0
        return true

class DataMapEngine

    constructor: (@dataSetName) ->

        if !@dataSetName?
            @dataSetName = "globalds"

        @emitter = new EvEmitter();
        @memData = {}

    on: (eventName, callbackFunction) =>
        @emitter.on eventName, callbackFunction

    off: (eventName, callbackFunction) =>
        @emitter.off eventName, callbackFunction

    ##|
    ##|  Erase all the data in a given table
    eraseCollection: (collectionName) =>
        @memData[collectionName] = new DataMapMemoryCollection(collectionName)

    export: (collectionName)=>
        c    = @internalGetCollection collectionName
        return c.export()

    delete: (pathText) =>

        path = @parsePath pathText
        c    = @internalGetCollection path.collection
        return c.remove path.condition

    ##|
    ##|  Find all the records in a given collection
    find: (collectionName, filterFunction) =>
        c = @internalGetCollection collectionName
        return c.findAll filterFunction

    ##|
    ##|  Return the end value from a stored value
    ##|  without creating a duplicate, this can screw with the data
    ##|  so it should be used for display or read only
    getFast: (collectionName, keyValue, subPath) =>

        ##|
        ##|  Path should already be parsed into an object.

        if !collectionName?
            throw new Error "Missing collection name"

        if typeof keyValue == "string" and checkForNumber.test keyValue
            keyValue = parseFloat keyValue

        c = @internalGetCollection collectionName
        return c.findFast keyValue, subPath

    ##|
    ##|  Return the end value from a stored value
    ##|  without creating a duplicate, this can screw with the data
    ##|  so it should be used for display or read only
    setFast: (collectionName, keyValue, subPath, newValue) =>

        ##|
        ##|  Path should already be parsed into an object.

        if !collectionName?
            throw new Error "Missing collection name"

        if typeof keyValue == "string" and checkForNumber.test keyValue
            keyValue = parseFloat keyValue

        c = @internalGetCollection collectionName
        return c.setFast keyValue, subPath, newValue

    ##|
    ##|  Return all the values for a given table row
    getFastRow: (collectionName, keyValue) =>

        ##|
        ##|  Path should already be parsed into an object.

        if !collectionName?
            throw new Error "Missing collection name"

        if typeof keyValue == "string" and checkForNumber.test keyValue
            keyValue = parseFloat keyValue

        c = @internalGetCollection collectionName
        return c.findFastRow keyValue, "/"

    ##| -------------------------------------------------------------------------------------------------------------
    ##|
    ##|  Get data from the engine using a given path
    ##|  create the record if needed which is generally used when you want to lock
    ##|  the data and them insert the record later.
    ##|
    get: (pathText, insertIfNeeded) =>

        path = @parsePath pathText
        c    = @internalGetCollection path.collection
        doc  = c.find path.condition

        if insertIfNeeded? and !doc?
            doc = $.extend true, {}, path.condition
            insertedDoc = c.upsert doc

        if path.subPath? and path.subPath.length > 0 and doc?

            basePointer = doc
            for name in path.subPath
                if !basePointer[name]?
                    basePointer[name] = {}
                basePointer = basePointer[name]

            return basePointer

        return doc

    ##| -------------------------------------------------------------------------------------------------------------
    ##|  Identifies changes in the src object compared to the target
    ##|
    deepDiff: (src, target, basePath) =>

        if !src?
            src = {}

        diffs = []
        for i, o of target
            if typeof o == "Object"
                results = @deepDiff src[i], o, basePath + "/" + i
                for d in results
                    diffs.push d
            else if !src[i]?
                diffs.push
                    path : basePath + "/#{i}"
                    kind : "N"
                    rhs  : o
            else if src[i] != o
                diffs.push
                    path : basePath + "/#{i}"
                    kind : "E"
                    lhs  : src[i]
                    rhs  : o

        for i, o of src
            if !target[i]?
                diffs.push
                    path : basePath + "/#{i}"
                    kind : "D"
                    lhs  : o

        return diffs

    ##|
    ##|  Set an entire document
    setFastDocument: (tableName, keyValue, newData)=>

        c = @internalGetCollection tableName
        if keyValue? then newData.id = keyValue
        c.upsert newData
        true


    ##| -------------------------------------------------------------------------------------------------------------
    ##|
    ##|  Save data to the engine
    set: (pathText, newData) =>

        path = @parsePath(pathText)

        ##|
        ##|  Get the full document, no subpath
        doc = @get
            condition: path.condition
            collection: path.collection
        , true

        ##|
        ##|  Unmodified version for change tracking
        if Object.keys(doc).length < 2
            ##|
            ##|  Fastest path because there are no differences on a new document
            ##|
            c = @internalGetCollection path.collection
            newData.id  = doc.id
            insertedDoc = c.upsert(newData)
            return insertedDoc

        origDoc = $.extend true, {}, doc

        basePointer = origDoc
        if path.subPath? and path.subPath.length > 0 and doc?

            for name in path.subPath
                # console.log "name=", name, " base=", basePointer
                if !basePointer[name]?
                    basePointer[name] = {}
                basePointer = basePointer[name]

        DataMapEngine.deepMergeObject basePointer, newData

        ##|
        ##|  Insert saved document
        c = @internalGetCollection path.collection
        insertedDoc = c.upsert(origDoc)

        ##|
        ##|  Events when data changed
        diffs = @deepDiff doc, origDoc, "/#{path.collection}/#{path.condition.id}"
        for d in diffs
            @emitter.emitEvent 'change', [ d ]

        ##|
        ##|
        return insertedDoc

    ##|
    ##| Overwrite one of the functions for an in memory table
    setDataCallback: (tableName, methodName, callback)=>

        collection = @internalGetCollection(tableName)
        collection[methodName] = callback


    ##| -------------------------------------------------------------------------------------------------------------
    ##|
    ##|  Return a reference to a table engine for the given table name
    internalGetCollection: (tableName, indexList) =>

        if !@memData[tableName]?
            @memData[tableName] = new DataMapMemoryCollection(tableName, indexList)

        return @memData[tableName]

    ##| -------------------------------------------------------------------------------------------------------------
    ##|
    ##|  Convert a path into information able to search and locate the record
    ##|  returns defined by result at the top of the function.
    ##|
    ##|  @param [string] a data path in the form of /tablename/[keyName:]value/subpath/subpath...
    ##|  @return [object] { collection: [string], condition [Mongo/Loki search], subPath: [array] }
    ##|
    parsePath: (path) =>

        ##|
        ##| if path is already parsed, just return it
        if path? and path.collection?
            return path

        ##|
        ##| Path must be /collection/[keyName:]value/subpath/subpath
        result =
            collection : "unknown"
            condition  : {}
            subPath    : null

        path = path.replace "//", "/"

        parts = path.split '/'
        if path.charAt(0) == '/' then parts.shift()
        if !parts? or !parts.length or parts.length < 2
            console.log "Error parsing path [#{path}]"
            return result

        result.collection = parts.shift()

        ##|
        ##|  Split the value which may contain a key
        keyParts = parts.shift().split ':'
        if keyParts[0]? and keyParts[1]?
            result.condition[keyParts[0]] = @getConditionValue keyParts[1]
        else
            result.condition["id"]  = @getConditionValue keyParts[0]

        if parts.length > 0
            if parts[parts.length-1].length == 0
                parts.pop()
            result.subPath = parts
        else
            result.subPath = []

        return result

    ##|
    ##|  Get the value in the correct data type
    getConditionValue: (value) =>

        if typeof value == "string" and checkForNumber.test value
            return parseFloat value

        return value

    ##|
    ##|  General helper function to deep copy / clone an object
    @deepMergeObject : (objTarget, objSrc, addAttributes, deleteAttributes, counter) ->

        # console.log "DEEP=", objSrc
        if counter > 5 then return objTarget

        if !objTarget? then return null
        if !objSrc? then return null
        if !counter? then counter = 1

        flagFound = false
        for i, o of objSrc

            if o == null
                objTarget[i] = null

            else if o instanceof Date
                objTarget[i] = new Date(o.getTime())
                flagFound = true

            else if typeof o isnt 'object'
                objTarget[i] = o
                flagFound = true

            else
                if !objTarget[i]
                    objTarget[i] = {}

                DataMapEngine.deepMergeObject objTarget[i], o, addAttributes, deleteAttributes, counter+1

            if flagFound and addAttributes?
                for x, y of addAttributes
                    objTarget[x] = y

            if flagFound and deleteAttributes?
                for x in deleteAttributes
                    delete objTarget[x]

        return objTarget