reDate2           = /[0-9\-]+T[0-9\:\.]+Z$/
checkForNumber    = /^[\d\-\.]+$/

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
                allResults.push $.extend(true, {}, obj)

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

            ##|
            ##| Complex search
            allResult = []
            for key, obj of @data
                found = false
                for i, o of condition
                    if obj[i] != o then found = false
                if found
                    # allResult.push $.extend(true, {}, o)
                    allResult.push o

            return allResult

    ##|
    ##|  Find a single record for read-online
    findFast: (idValue, subKey) =>

        if idValue? and @data[idValue]?
            return @data[idValue][subKey]
        else
            return null

    ##|
    ##|  Fully update the document in memory
    ##|

    upsert: (doc) =>

        strKey = @getDocumentKey(doc)
        @data[strKey] = $.extend(true, {}, doc);
        @count = Object.keys(@data).length
        return @data[strKey]

    ##|
    ##|  Remove a key
    remove: (condition) =>

        allResults = @find condition
        if !allResults? then remove
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

        c = @internalGetCollection collectionName
        return c.eraseCollection()

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

        if typeof keyValue == "string" and /^[0-9]+$/.test keyValue
            keyValue = parseInt keyValue

        c = @internalGetCollection collectionName
        return c.findFast keyValue, subPath

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
        origDoc = $.extend true, {}, doc

        basePointer = doc
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
        insertedDoc = c.upsert(doc)

        ##|
        ##|  Events when data changed
        diffs = @deepDiff origDoc, doc, "/#{path.collection}/#{path.condition.id}"
        for d in diffs
            @emitter.emitEvent 'change', [ d ]

        ##|
        ##|
        return insertedDoc


    ##| -------------------------------------------------------------------------------------------------------------
    ##|
    ##|  Internally Loki stores data in collections that are like tables within the database.
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