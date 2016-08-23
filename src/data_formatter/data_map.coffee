## -------------------------------------------------------------------------------------------------------------
## function to open globalEditor which is simple textbox
##
## @param [Element] e the element in which the editor to create
## @return [Boolean]
##

reDate1 = /^[0-9][0-9][0-9][0-9].[0-9][0-9].[0-9][0-9]T00.00.00.000Z/
reDate2 = /^[0-9][0-9][0-9][0-9].[0-9][0-9].[0-9][0-9]T[0-9][0-9].[0-9][0-9].[0-9][0-9].[0-9][0-9][0-9]Z/

globalOpenEditor = (e) ->
	##|
	##|  Clicked on an editable field
	path = $(e).attr("data-path")
	DataMap.getDataMap().editValue path, e
	false

window.newPromise = (callFunction, context)->

	return new Promise (resolve, reject) ->

		if !callFunction?
			resolve(true)

		##|
		##|  parameter is a generator or something that co supports
		co(callFunction).call (context || this), (err, value)->
			if err
				console.log "ERR:", err
				reject(err)

			resolve(value)

root = exports ? this

## -------------------------------------------------------------------------------------------------------------
## class DataMap
## this is the class to handle and map the data into application including custom data types and data for that datatypes
##
class DataMap

	## -------------------------------------------------------------------------------------------------------------
	## constructor
	##
	constructor: (@dataSetName)->

		# @property [Object] data to save the data objects
		@data     = {}

		# @property [Object] types to save datatypes for the column in table
		@types    = {}

		# @property [Function] onSave function to be called when edited data is saved
		@onSave   = {}

		# @property [Object] objStore object store
		@objStore = {}

		##|  Cached values for display
		@cachedFormat = {}

		@engine = new DataMapEngine()
		@engine.on "change", (diff, a, b)=>

			if diff.kind == "E"
				@updateScreenPathValue diff.path, diff.lhs, true

		GlobalClassTools.addEventManager(this)

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

	## ===[ Utilities / helper functions on the data ]===

	## -------------------------------------------------------------------------------------------------------------
	## initiate the edit of the data using editor defined in the data type
	##
	## @param [String] path indicating the location of the data beign edited
	## @param [JqueryElement] el element in which to open editor
	## @return [Boolean]
	##
	editValue: (path, el) =>

		parts     = path.split '/'
		tableName = parts[1]
		keyValue  = parts[2]
		fieldName = parts[3]

		existingValue = @engine.getFast tableName, keyValue, fieldName
		formatter     = @types[tableName].col[fieldName].formatter

		##|
		##|  Fix the options in the global formatter object
		if @types[tableName].col[fieldName].options?
			formatter.options = @types[tableName].col[fieldName].options

		formatter.editData el, existingValue, path, @updatePathValueEvent
		return true

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

		delete @cachedFormat[path]

		result = $("[data-path='#{path}']")
		if result.length > 0

			currentValue = newValue

			if @types[tableName]? and @types[tableName].col[fieldName]?
				formatter    = @types[tableName].col[fieldName].formatter
				currentValue = formatter.format currentValue, @types[tableName].col[fieldName].options, path
				result.html currentValue

			if didDataChange then result.addClass "dataChanged"

		##|
		##|  Broadcast the data change event
		if globalKeyboardEvents? and didDataChange
			globalKeyboardEvents.emitEvent "change", [path, newValue]

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

		delete @cachedFormat[path]
		existingValue = @engine.getFast tableName, keyValue, fieldName

		##| check if the existing type is boolean
		if typeof existingValue == 'boolean' and existingValue == Boolean(newValue) then return true
		if existingValue == newValue then return true

		# console.log "setFast t=#{tableName} k=#{keyValue} field=#{fieldName} new=#{newValue}"
		DataMap.getDataMap().engine.setFast tableName, keyValue, fieldName, newValue
		@updateScreenPathValue path, newValue, true

		if @onSave[tableName]?
			@onSave[tableName](keyValue, fieldName, existingValue, newValue)

		true

	@putFormattedValueToCell: (widgetCell, tableName, fieldName, keyValue) =>

		dm = DataMap.getDataMap()

		if typeof keyValue == "string" and /^[0-9]{1,12}$/.test keyValue
			keyValue = parseInt(keyValue)

		path = "/" + tableName + "/" + keyValue + "/" + fieldName
		delete @cachedFormat[path]

		widgetCell.setDataPath path
		currentValue = DataMap.getDataField tableName, keyValue, fieldName

		##|
		##|  See if there is a formatter attached
		if dm.types[tableName]? and dm.types[tableName].col[fieldName]?

			formatter = dm.types[tableName].col[fieldName].formatter

			if formatter? and formatter
				currentValue = formatter.format currentValue, dm.types[tableName].col[fieldName].options, path

			if dm.types[tableName].col[fieldName].render? and typeof dm.types[tableName].col[fieldName].render == "function"
				currentValue = dm.types[tableName].col[fieldName].render(currentValue, path)

			if dm.types[tableName].col[fieldName].editable
				widgetCell.addClass "editable"
			else
				widgetCell.removeClass "editable"

		if !currentValue? or currentValue == null
			currentValue = ""

		widgetCell.text currentValue
		return

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
	## >>> RETURNS A PROMISE
	@renderField: (tagNam, tableName, fieldName, keyValue, extraClassName) =>

		dm = DataMap.getDataMap()

		if typeof keyValue == "string" and /^[0-9]{1,12}$/.test keyValue
			keyValue = parseInt(keyValue)

		path = "/" + tableName + "/" + keyValue + "/" + fieldName
		className = "data"

		currentValue = DataMap.getDataField tableName, keyValue, fieldName

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

	## ===[ Events ]===

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

	## ===[ Dealing with Schema (column definitions) ]===

	## -------------------------------------------------------------------------------------------------------------
	## Import the given data types from a saved selection
	##
	## @param [String] tableName table name for which the new data type is being set
	## @param [Object] columns containing data types
	##
	@importDataTypes: (tableName, savedConfig) =>

		dm = DataMap.getDataMap()
		dm.types[tableName] = new DataTypeCollection(tableName)

		for sourceName, obj of savedConfig
			if sourceName == "_lastModified" then continue
			if typeof obj != "object" then continue

			if obj.render and typeof obj.render == "string" and obj.render.length > 1
				##|
				##| Convert to a function
				functionText = DataTypeCollection.renderFunctionToString(obj.render)
				obj.render   = DataTypeCollection.renderStringToFunction(functionText)

			dm.types[tableName].configureColumns [ obj ]

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

	##|
	##|  Remove all the data from a table
	@eraseCollection: (tableName) =>
		dm = DataMap.getDataMap()
		dm.engine.eraseCollection(tableName)
		dm.cachedFormat = {}
		return true

	@removeTableData: (tableName) =>
		dm = DataMap.getDataMap()
		dm.engine.eraseCollection(tableName)
		dm.cachedFormat = {}
		return true

	##|
	##|  Entirely remove a table
	@removeTable: (tableName) =>

		dm = DataMap.getDataMap()
		dm.engine.eraseCollection(tableName)
		delete dm.types[tableName]
		dm.cachedFormat = {}
		return true

	##|
	##|  Add a column data type
	@addColumn: (tableName, options) =>

		# console.log "Adding column #{tableName}:", options

		config =
			name     : "New Column"
			source   : "newcol"
			visible  : true
			hideable : false
			editable : false
			sortable : true
			required : false
			align    : "left"
			type     : "text"
			width    : null
			tooltip  : ""
			render   : null

		$.extend config, options

		DataMap.setDataTypes tableName, [ config ]
		dm = DataMap.getDataMap()
		dm.types[tableName].col[config.source].formatter = globalDataFormatter.getFormatter config.type

		if config.render?
			functionText = DataTypeCollection.renderFunctionToString(config.render)
			dm.types[tableName].col[config.source].render = DataTypeCollection.renderStringToFunction(functionText)

		# console.log "addColumn Setting formatter for #{config.type}=", dm.types[tableName].col[config.source].formatter
		return dm.types[tableName].col[config.source]

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

		updated = false
		for i, o of objects
			if dm.setDataTypesFromSingleObject(tableName, o)
				updated = true

		true

	setDataTypesFromSingleObject: (tableName, newData)=>

		if !@types[tableName]?
			@types[tableName] = new DataTypeCollection(tableName)

		##|
		##|  Returns updated = true if the data type(s) found in this table
		##|  are new or different than before.
		##|  TODO:  Check to see if something we assumed before, such as a blank value
		##|  or a number may contain a less restricitve type now and convert the
		##|  column to something like text.
		##|

		updated = false
		for keyName, value of newData
			if keyName == "_id" then continue
			if keyName == "loc" then continue

			found = @types[tableName].contains(keyName)
			if found == null or found == false

				colName = keyName.charAt(0).toUpperCase() + keyName[1..]
				colName = colName.replace(/([a-z])([A-Z])/g, "$1 $2")

				config =
					name     : colName
					source   : keyName
					editable : false
					visible  : true
					type     : "text"
					required : false
					hideable : true
					width    : ""
					align    : ""
					options  : ""

				if keyName == "distance"
					config.type     = "distance"
					config.width    = 60
					config.align    = "right"
				else if /^http/.test value
					config.type  = "link"
					config.align = "center"
					config.width = 90
				else if /Year/.test keyName
					config.type     = "number"
					config.width    = 60
					config.align    = "right"
					config.options  = '####'
				else if reDate2.test value or reDate1.test value
					config.type     = "datetime"
					config.width    = 120
					config.align    = "left"
				else if typeof value == "number" or /^[\-0-9]{0,1}[0-9]{1,11}$/.test value
					config.type     = "number"
					config.width    = 66
					config.align    = "right"
				else if value? and typeof value == "object" and value.getTime?
					config.type = "datetime"
					config.width    = 110
				else if typeof value == "object"
					config.type     = "simpleobject"
					config.width    = 60

				if keyName == "id"
					config.type     = "text"
					config.name     = "ID"
					# config.visible  = false
					config.hideable = true

				if /MLS/.test(keyName) and config.type == "number"
					config.type  = "text"
					config.width = 90

				updated = true
				# console.log "Adding ", config.name, config
				DataMap.addColumn tableName, config

		return updated


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

	## ===[ Importing Data ]===

	## -------------------------------------------------------------------------------------------------------------
	## Quickly import an entire array of objects into table clears the table first
	##
	## @param [String] tableName table name for which the new data type is being set
	## @param [Array] objects array of objects to set in the table in form of 2d array
	## @return [Boolean]
	##
	@importDataFromObjects: (tableName, objects) =>

		# console.log "importDataFromObjects table=#{tableName} Obj=", objects
		# console.log JSON.stringify(objects)

		dm = DataMap.getDataMap()
		for i, o of objects
			@addDataUpdateTable tableName, i, o

		true

	## ===[ Exporting / Retreiving Data ]===

	@setDataCallback: (tableName, methodName, callback)=>
		return DataMap.getDataMap().engine.setDataCallback tableName, methodName, callback

	## -------------------------------------------------------------------------------------------------------------
	## get the values of the columns which will be retured true by reduceFunction
	##
	## @param [String] tableName table name for which the new data type is being set
	## @param [Function] reduceFunction function that will called on each column and if returns true then it will considered
	## @return [Array] results the array of the data included using reduceFunction
	##
	@getValuesFromTable: (tableName, reduceFunction) =>
		return DataMap.getDataMap().engine.find tableName, reduceFunction

	## -------------------------------------------------------------------------------------------------------------
	## add data to the dataMap and update the occurence on the currently rendered screen
	##
	## @param [String] tableName name of the table in which the data is being added
	## @param [String] keyValue unique key to track the data row inside the DataMap
	## @param [Object] values values of the row in form of object
	## @return [Boolean]
	##
	@addData: (tableName, keyValue, newData) =>

		path = "/#{tableName}/#{keyValue}"
		doc = DataMap.getDataMap().engine.set path, newData

		dm = DataMap.getDataMap()
		dm.emitEvent "new_data", [ tableName, keyValue ]

		return doc

	## -------------------------------------------------------------------------------------------------------------
	## Change the data type of a column
	##
	@changeColumnType: (tableName, sourceName, newType, ignoreEvents)=>

		dm = DataMap.getDataMap()
		if !dm.types[tableName]? then return false
		if dm.types[tableName].col[sourceName]?
			dm.types[tableName].col[sourceName].type = newType
			dm.types[tableName].col[sourceName].formatter = globalDataFormatter.getFormatter newType

			if newType == "number"
				dm.types[tableName].col[sourceName].align = "right"

			saveText = dm.types[tableName].toSave()
			if ignoreEvents? and ignoreEvents == true or !globalTableEvents?
				return true

			dm.emitEvent "table_change", [tableName, saveText]
			globalTableEvents.emitEvent "table_change", [ tableName, sourceName, "type", newType ]

			return true

		return false

	@changeColumnOrder: (tableName, sourceName, newValue, ignoreEvents)=>

		if !ignoreEvents?
			globalTableEvents.emitEvent "table_change", [ tableName, sourceName, "order", newValue ]

		dm = DataMap.getDataMap()
		dm.cachedFormat = {}
		oldOrder = dm.types[tableName].col[sourceName].order
		console.log "oldOrder=#{oldOrder} new=#{newValue}"
		for source, c of dm.types[tableName].col
			if c.order < newValue then continue
			if c.order > oldOrder then continue
			c.order = c.order + 1
			if !ignoreEvents?
				globalTableEvents.emitEvent "table_change", [ tableName, source, "order", c.order ]

		 dm.types[tableName].col[sourceName].order = newValue
		 if !ignoreEvents?
		 	saveText = dm.types[tableName].toSave()
		 	dm.emitEvent "table_change", [tableName, saveText]

		true

	## -------------------------------------------------------------------------------------------------------------
	## Change an attribute from an active table
	##
	@changeColumnAttribute: (tableName, sourceName, field, newValue, ignoreEvents)=>

		if field == "type" then return @changeColumnType(tableName, sourceName, newValue, ignoreEvents)

		dm = DataMap.getDataMap()
		dm.cachedFormat = {}
		if !dm.types[tableName]?
			return false

		if dm.types[tableName].col[sourceName]?

			##|
			##|  Special case for column order
			if field == "order"
				@changeColumnOrder(tableName, sourceName, newValue, ignoreEvents)
				return true

			if field == "render"
				renderText = DataTypeCollection.renderFunctionToString(newValue)
				render     = DataTypeCollection.renderStringToFunction(renderText)
				dm.types[tableName].col[sourceName][field] = render
				newValue = renderText
			else
				dm.types[tableName].col[sourceName][field] = newValue

			if ignoreEvents? and ignoreEvents == true or !globalTableEvents?
				return true

			##|
			##| Send chagne event
			globalTableEvents.emitEvent "table_change", [ tableName, sourceName, field, newValue ]

			saveText = dm.types[tableName].toSave()
			dm.emitEvent "table_change", [tableName, saveText]

			return true

		return false

	@changeColumn: (tableName, newColumn)=>

		dm = DataMap.getDataMap()
		if !dm.types[tableName]?
			dm.types[tableName] = new DataTypeCollection(tableName)

		# console.log "HERE:", newColumn

		found = false
		if !dm.types[tableName].col[newColumn.col.source]?
			dm.types[tableName].colList.push newColumn.col.source

		dm.types[tableName].col[newColumn.col.source] = newColumn

	@addDataUpdateTable: (tableName, keyValue, newData) =>

		path = "/#{tableName}/#{keyValue}"
		doc = DataMap.getDataMap().engine.set path, newData

		dm = DataMap.getDataMap()
		if !dm.types[tableName]?
			dm.types[tableName] = new DataTypeCollection(tableName)

		updated = dm.setDataTypesFromSingleObject(tableName, newData)

		if updated
			saveText = dm.types[tableName].toSave()
			dm.emitEvent "table_change", [tableName, saveText]

		# console.log "Sending new data alert"
		dm.emitEvent "new_data", [ tableName, keyValue ]
		return doc

	## -------------------------------------------------------------------------------------------------------------
	## delete row form the screen and dataMap using the keyvale
	##
	## @param [String] tableName name of the table in which the data is being added
	## @param [String] keyValue unique key to track the data row inside the DataMap
	## @return [Boolean]
	##
	## >>> RETURNS A PROMISE
	@deleteDataByKey: (tableName, keyValue) =>
		dm = DataMap.getDataMap()
		return dm.engine.delete "/#{tableName}/#{keyValue}"

	## -------------------------------------------------------------------------------------------------------------
	## get the data for a given key
	##
	## @param [String] tableName name of the table in which the data is being added
	## @param [String] keyValue unique key to track the data row inside the DataMap
	## @return [String]
	##
	@getDataForKey: (tableName, keyValue) =>
		dm = DataMap.getDataMap()
		return dm.engine.getFastRow tableName, keyValue

	## -------------------------------------------------------------------------------------------------------------
	## get the single column|field value using the key and column name
	##
	## @param [String] tableName name of the table in which the data is being added
	## @param [String] keyValue unique key to track the data row inside the DataMap
	## @param [String] fieldName name of the column to return the value of
	## @return [String]
	##
	## >>> RETURNS A PROMISE
	@getDataField: (tableName, keyValue, fieldName) =>

		dm = DataMap.getDataMap()
		return dm.engine.getFast tableName, keyValue, fieldName

	@getDataFieldFormatted: (tableName, keyValue, fieldName) =>

		path = "/" + tableName + "/" + keyValue + "/" + fieldName
		dm = DataMap.getDataMap()

		if dm.cachedFormat[path]?
			return dm.cachedFormat[path]

		currentValue = DataMap.getDataField tableName, keyValue, fieldName

		##|
		##|  See if there is a formatter attached

		if dm.types[tableName]? and dm.types[tableName].col[fieldName]?

			formatter = dm.types[tableName].col[fieldName].formatter

			if dm.types[tableName].col[fieldName].render?
				currentValue = dm.types[tableName].col[fieldName].render(currentValue, tableName, fieldName, keyValue)

			else if formatter? and formatter
				currentValue = formatter.format currentValue, dm.types[tableName].col[fieldName].options, path

		if !currentValue? or currentValue == null
			currentValue = ""

		dm.cachedFormat[path] = currentValue
		return currentValue
