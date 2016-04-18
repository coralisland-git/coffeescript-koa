## -------------------------------------------------------------------------------------------------------------
## function to open globalEditor which is simple textbox
##
## @param [Element] e the element in which the editor to create
## @return [Boolean]
##
globalOpenEditor = (e) ->
    ##|
    ##|  Clicked on an editable field
    path = $(e).attr("data-path")
    DataMap.getDataMap().editValue path, e
    false


root = exports ? this

## -------------------------------------------------------------------------------------------------------------
## class DataMap
## this is the class to handle and map the data into application including custom data types and data for that datatypes
##
class DataMap

    ## -------------------------------------------------------------------------------------------------------------
	## constructor
	##
	constructor: ()->
        # @property [Object] data to save the data objects
        @data     = {}

        # @property [Object] types to save datatypes for the column in table
        @types    = {}

        # @property [Function] onSave function to be called when edited data is saved
        @onSave   = {}

        # @property [Object] objStore object store
        @objStore = {}

    ## -------------------------------------------------------------------------------------------------------------
	## function to get singleton global instance of data map
	##
	## @return [DataMap] globalDataMap global instance of dataMap
    ##
    @getDataMap: () =>
        ##
        if !root.globalDataMap
            root.globalDataMap = new DataMap()

        return root.globalDataMap

    ## -------------------------------------------------------------------------------------------------------------
	## Call this function to set a callback when an editable field changes
	## due to an inline editor.   The callback receives
	## Table Name, Key, Old Value, New Value
    ##
	## @param [String] tableName tableName to associate callback with
	## @param [Function] callbackFunction funtion to execute on save
	## @return [Boolean]
	##
    @setSaveCallback: (tableName, callbackFunction) =>

        dm = DataMap.getDataMap()
        dm.onSave[tableName] = callbackFunction

        true

    ## -------------------------------------------------------------------------------------------------------------
	## Set the data type for a given type of data Called statically to
	##
    ## @param [String] tableName table name for which the new data type is being set
    ## @param [Object] columns array of the columns to set as data type
	## @return [Boolean]
    ##
    @setDataTypes: (tableName, columns) =>

        dm = DataMap.getDataMap()

        if !dm.types[tableName]?
            dm.types[tableName] = new DataTypeCollection(tableName)

        dm.types[tableName].configureColumns columns

        true

    ## -------------------------------------------------------------------------------------------------------------
	## Quickly import an entire array of objects into table clears the table first
	##
    ## @param [String] tableName table name for which the new data type is being set
    ## @param [Array] objects array of objects to set in the table in form of 2d array
	## @return [Boolean]
    ##
    @importDataFromObjects: (tableName, objects) =>

        dm = DataMap.getDataMap()
        dm.data[tableName] = {}

        for i, o of objects
            @addData tableName, i, o

        true

    ## -------------------------------------------------------------------------------------------------------------
	## Reset the columns for a table based on some object
	##
    ## @param [String] tableName table name for which the new data type is being set
    ## @param [Object] columns array of the columns to set as data type
    ##
    @setDataTypesFromObject: (tableName, objects) =>

        dm = DataMap.getDataMap()
        dm.types[tableName] = new DataTypeCollection(tableName)

        obj = null
        minWidth = {}

        for i, o of objects
            if !obj?
                obj = o
                for dataName, dataValue of obj
                    minWidth[dataName] = dataName.length

            for dataName, dataValue of o
                len = dataValue.toString().length
                if len > minWidth[dataName]
                    minWidth[dataName] = len

        columns = []
        reDate1 = /^[0-9][0-9][0-9][0-9].[0-9][0-9].[0-9][0-9]T00.00.00.000Z/
        reDate2 = /^[0-9][0-9][0-9][0-9].[0-9][0-9].[0-9][0-9]T[0-9][0-9].[0-9][0-9].[0-9][0-9].[0-9][0-9][0-9]Z/

        for i, o of obj
            console.log "Check [#{i}] = ", o, " Type=", typeof o

            dataType = "text"
            if typeof o == "number"
                dataType = "number"

            else if reDate2.test o
                dataType = "datetime"

            else if reDate1.test o
                dataType = "date"

            col =
                name     : i
                source   : i
                visible  : true
                editable : false
                type     : dataType

            col.width = 20 + (10 * minWidth[i])
            columns.push col

        dm.types[tableName].configureColumns columns

    ## -------------------------------------------------------------------------------------------------------------
	## Return the columns associated with a given table
    ## reduceFunction is called with every table name and return the columns that return true
	##
    ## @param [String] tableName table name for which the new data type is being set
    ## @param [Function] reduceFunction function to validate the column if returns true column will be included
	## @return [Array] columns array of included columns
    ##
    @getColumnsFromTable: (tableName, reduceFunction) =>

        dm = DataMap.getDataMap()

        columns = []
        if !dm.types[tableName]
            return columns

        for i in dm.types[tableName].colList
            col = dm.types[tableName].col[i]

            keepColumn = true
            if reduceFunction?
                keepColumn = reduceFunction(col)

            if keepColumn
                columns.push col

        return columns

    ## -------------------------------------------------------------------------------------------------------------
	## get the values of the columns which will be retured true by reduceFunction
	##
    ## @param [String] tableName table name for which the new data type is being set
    ## @param [Function] reduceFunction function that will called on each column and if returns true then it will considered
	## @return [Array] results the array of the data included using reduceFunction
    ##
    @getValuesFromTable: (tableName, reduceFunction) =>

        dm = DataMap.getDataMap()
        # console.log "D[", tableName, "]=", dm.data[tableName]
        if !dm.data[tableName]? then return []

        results = []

        for key, obj of dm.data[tableName]
            keepRow = true
            if reduceFunction?
                keepRow = reduceFunction(obj)

            if keepRow
                results.push
                    key   : key
                    table : tableName

        return results

    ## -------------------------------------------------------------------------------------------------------------
	## initiate the edit of the data using editor defined in the data type
	##
    ## @param [String] path indicating the location of the data beign edited
    ## @param [JqueryElement] el element in which to open editor
	## @return [Boolean]
    ##
    editValue: (path, el) =>

        ##| Split the path name
        ##| ["", "zipcode", "03105", "lon"]
        parts = path.split '/'
        tableName = parts[1]
        keyValue  = parts[2]
        fieldName = parts[3]

        existingValue = @data[tableName][keyValue][fieldName]
        console.log "Existing:", existingValue
        formatter     = @types[tableName].col[fieldName].formatter
        console.log "F=", formatter
        formatter.editData el, existingValue, path, @updatePathValueEvent
        true

    ## -------------------------------------------------------------------------------------------------------------
	## update the occurence of the path value with the updated value on currently rendered screen
	##
    ## @param [String] path indicating the location of the data to be updated
    ## @param [Object] newValue new value to be set instead of old data
    ## @param [Boolean] didDataChange if data is different from the previous value
	## @return [Boolean]
    ##
    updateScreenPathValue: (path, newValue, didDataChange) =>

        parts     = path.split '/'
        tableName = parts[1]
        keyValue  = parts[2]
        fieldName = parts[3]

        result = $("[data-path='#{path}']")
        if result.length > 0

            currentValue = newValue

            if @types[tableName]? and @types[tableName].col[fieldName]?
                formatter    = @types[tableName].col[fieldName].formatter
                currentValue = formatter.format currentValue, @types[tableName].col[fieldName].options, path

            result.html currentValue
            if didDataChange then result.addClass "dataChanged"

        true

    ## -------------------------------------------------------------------------------------------------------------
	## works as the event triggered at the update of the value
	##
    ## @param [String] path indicating the location of the data to be updated
    ## @param [Object] newValue new value to be set instead of old data
    ## @event updatePathValueEvent
    ## @return [Boolean]
    ##
    updatePathValueEvent: (path, newValue) =>

        ##|
        ##|  Works just like updatePathValue except that an event is triggered (onSave) if available
        parts = path.split '/'
        tableName = parts[1]
        keyValue  = parts[2]
        fieldName = parts[3]

        existingValue = @data[tableName][keyValue][fieldName]
        ##| check if the existing type is boolean
        if typeof existingValue == 'boolean' and existingValue == Boolean(newValue) then return true

        if existingValue == newValue then return true

        @data[tableName][keyValue][fieldName] = newValue
        @updateScreenPathValue path, newValue, true

        if @onSave[tableName]?
            @onSave[tableName](keyValue, fieldName, existingValue, newValue)

        true

    ## -------------------------------------------------------------------------------------------------------------
	## update the occurence of the path value with the updated value in the internal data map
	##
    ## @param [String] path indicating the location of the data to be updated
    ## @param [Object] newValue new value to be set instead of old data
    ## @return [Boolean]
    ##
    updatePathValue: (path, newValue) =>

        ##| Split the path name
        ##| ["", "zipcode", "03105", "lon"]
        parts = path.split '/'
        tableName = parts[1]
        keyValue  = parts[2]
        fieldName = parts[3]

        existingValue = @data[tableName][keyValue][fieldName]
        # console.log "Compare ", existingValue, " to ", newValue
        if existingValue == newValue then return true
        @data[tableName][keyValue][fieldName] = newValue
        @updateScreenPathValue path, newValue, true

        true

    ## -------------------------------------------------------------------------------------------------------------
	## save the current data state
	##
    @stateSave: () =>
        # TODO: Figure out a better way to save and load state
        # dm = DataMap.getDataMap()
        # localStorage["DataMap"] = JSON.stringify(dm.data)
        return

    ## -------------------------------------------------------------------------------------------------------------
	## load the state
	##
    @stateLoad: () =>
        # TODO: Figure out a better way to save state
        # jtext = localStorage["DataMap"]
        # if jtext? and jtext != null
        #     dm = DataMap.getDataMap()

        #     try
        #         dm.data = JSON.parse(jtext)
        #     catch
        #         dm.data = {}

        return

    ## -------------------------------------------------------------------------------------------------------------
	## add data to the dataMap and update the occurence on the currently rendered screen
	##
    ## @param [String] tableName name of the table in which the data is being added
    ## @param [String] keyValue unique key to track the data row inside the DataMap
    ## @param [Object] values values of the row in form of object
	## @return [Boolean]
    ##
    @addData: (tableName, keyValue, values) =>

        dm = DataMap.getDataMap()

        # console.log "addData[", tableName, "][", keyValue, "][", values ,"]"

        if !dm.data[tableName]
            dm.data[tableName] = {}

        if !dm.data[tableName][keyValue]
            ##|
            ##|  Entirely new value, don't check for updates
            dm.data[tableName][keyValue] = values
            for keyName, subkeyVal of values
                dm.updateScreenPathValue "/#{tableName}/#{keyValue}/#{keyName}", subkeyVal, false
            return true

        for varName, value of values
            path = "/#{tableName}/#{keyValue}/#{varName}"
            dm.updatePathValue path, value

        true

    ## -------------------------------------------------------------------------------------------------------------
	## delete row form the screen and dataMap using the keyvale
	##
    ## @param [String] tableName name of the table in which the data is being added
    ## @param [String] keyValue unique key to track the data row inside the DataMap
    ## @return [Boolean]
    ##
    @deleteDataByKey: (tableName, keyValue) =>
        dm = DataMap.getDataMap()

        if dm.data[tableName] and dm.data[tableName][keyValue]
            ##| remove table row if found
            if $("[data-path^='/#{tableName}/#{keyValue}/']").length
                $("[data-path^='/#{tableName}/#{keyValue}/']").parent('tr').remove()

            delete dm.data[tableName][keyValue]
            $("[data-path^='/#{tableName}/#{keyValue}/']").html ""

        true

    ## -------------------------------------------------------------------------------------------------------------
	## get the single column|field value using the key and column name
	##
    ## @param [String] tableName name of the table in which the data is being added
    ## @param [String] keyValue unique key to track the data row inside the DataMap
    ## @param [String] fieldName name of the column to return the value of
	## @return [String]
    ##
    @getDataField: (tableName, keyValue, fieldName) =>

        dm = DataMap.getDataMap()
        if !dm.data[tableName]? or !dm.data[tableName][keyValue]?
            return ""

        return dm.data[tableName][keyValue][fieldName]

    ## -------------------------------------------------------------------------------------------------------------
	## return the html for the column to render including events and all
	##
    ## @param [String] tagNam tag name to be used for ex. li
    ## @param [String] tableName tableName for which the current render is being done
    ## @param [String] fieldName name of the column which is currently under render
    ## @param [String] keyValue unique keyValue to track the current row
    ## @param [String] extraClassName additional style class to inlude in the html
	## @return [String] html
    ##
    @renderField: (tagNam, tableName, fieldName, keyValue, extraClassName) =>

        dm = DataMap.getDataMap()

        path = "/" + tableName + "/" + keyValue + "/" + fieldName
        currentValue = ""

        className = "data"

        if dm.data[tableName]? and dm.data[tableName][keyValue]? and dm.data[tableName][keyValue][fieldName]?
            currentValue = dm.data[tableName][keyValue][fieldName]

        ##|
        ##|  Other modification to the HTML such as edit events
        otherhtml = ""

        ##|
        ##|  See if there is a formatter attached
        if dm.types[tableName]? and dm.types[tableName].col[fieldName]?

            formatter = dm.types[tableName].col[fieldName].formatter

            if formatter? and formatter
                currentValue = formatter.format currentValue, dm.types[tableName].col[fieldName].options, path
                className += " dt_" + formatter.name

            if dm.types[tableName].col[fieldName].render? and typeof dm.types[tableName].col[fieldName].render == "function"
                currentValue = dm.types[tableName].col[fieldName].render(currentValue, path)

            if dm.types[tableName].col[fieldName].editable
                otherhtml += " onClick='globalOpenEditor(this);' "
                className += " editable"

        if extraClassName? and extraClassName.length > 0
            className += " #{extraClassName}"

        if !currentValue? or currentValue == null
            currentValue = ""

        # console.log "path=", path, dm.types[tableName].col[fieldName]

        html = "<#{tagNam} data-path='#{path}' class='#{className}' #{otherhtml}>" +
            currentValue + "</#{tagNam}>"

        return html
