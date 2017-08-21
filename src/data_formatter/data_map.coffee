## -------------------------------------------------------------------------------------------------------------
## function to open globalEditor which is simple textbox
##
## @param [Element] e the element in which the editor to create
## @return [Boolean]
##
DataSetConfig = require 'edgecommondatasetconfig'

globalOpenEditor = (e) ->
	##|
	##|  Clicked on an editable field
	#console.log "GlobalOpenEditor:", e
	data = WidgetTag.getDataFromEvent(e)
	#console.log "GlobalOpenEditor Data:", data
	path = data.path
	DataMap.getDataMap().editValue path, e.target
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
		formatter     = @types[tableName].col[fieldName].getFormatter()

		##|
		##|  Fix the options in the global formatter object
		formatter.options = @types[tableName].col[fieldName].getOptions()

		#console.log "editValue path=#{path} table=#{tableName}, keyValue=#{keyValue}, field=#{fieldName}"
		#console.log "Formatter:", formatter

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

		##|
		##|  Remove any cached values that happen to exist
		dm = DataMap.getDataMap()
		for col in DataMap.getColumnsFromTable(tableName)
			delete dm.cachedFormat["/#{tableName}/#{keyValue}/#{col.getSource()}"]

		existingValue = @engine.getFast tableName, keyValue, fieldName

		##| check if the existing type is boolean
		if typeof existingValue == 'boolean' and existingValue == Boolean(newValue) then return true
		if existingValue == newValue then return true

		dm.engine.setFast tableName, keyValue, fieldName, newValue
		@updateScreenPathValue path, newValue, true

		if @onSave[tableName]?
			@onSave[tableName](keyValue, fieldName, existingValue, newValue)

		true

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
		dm.types[tableName] = new DataSetConfig.Table(tableName)

		for sourceName, obj of savedConfig

			if sourceName == "_lastModgetified" then continue
			if typeof obj != "object" then continue
			dm.types[tableName].unserialize([ obj ], true)

		# console.log  "importDataTypes table=#{tableName}:", dm.types[tableName]

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
		   dm.types[tableName] = new DataSetConfig.Table(tableName)

		dm.types[tableName].unserialize columns

		# console.log "ADDING:", tableName, columns
		# console.log dm.types[tableName]
		true

	##|
	##|  Remove the table's data but leave all column types
	##|
	@removeTableData: (tableName) =>
		dm = DataMap.getDataMap()
		dm.engine.eraseCollection(tableName)
		dm.cachedFormat = {}
		return true

	##|
	##|  Entirely remove a table including all data and all
	##|  data types.
	##|
	@removeTable: (tableName) =>

		dm = DataMap.getDataMap()
		dm.engine.eraseCollection(tableName)
		delete dm.types[tableName]
		dm.cachedFormat = {}
		return true

	##|
	##|  Add a column data type
	@addColumn: (tableName, options) =>

		config =
			name        : "New Column"
			source      : "newcol"
			visible     : true
			hideable    : false
			editable    : false
			sortable    : true
			required    : false
			align       : "left"
			type        : "text"
			width       : null
			tooltip     : ""
			render      : null
			calculation : false

		$.extend config, options

		DataMap.setDataTypes tableName, [ config ]
		dm = DataMap.getDataMap()

		##|
		##|  Save this new column entirely
		##|
		saveText = dm.types[tableName].serialize()
		dm.emitEvent "table_change", [tableName, saveText]
		return dm.types[tableName].col[config.source]

	## -------------------------------------------------------------------------------------------------------------
	## Reset the columns for a table based on some object
	##
	## @param [String] tableName table name for which the new data type is being set
	## @param [Object] columns array of the columns to set as data type
	##
	@setDataTypesFromObject: (tableName, objects) =>

		dm = DataMap.getDataMap()
		dm.types[tableName] = new DataSetConfig.Table(tableName)

		updated = false
		for i, o of objects
			if dm.setDataTypesFromSingleObject(tableName, o)
				updated = true

		if updated then dm.cachedFormat = {}
		return updated

	setDataTypesFromSingleObject: (tableName, newData)=>

		if !@types[tableName]?
			@types[tableName] = new DataSetConfig.Table(tableName)

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
			# if keyName == "id" then continue
			if keyName.charAt(0) == '_' then continue
			if keyName == "hash" then continue

			found = @types[tableName].getColumn(keyName)
			if !found?

				colName = keyName.replace(/([a-z])([A-Z])/g, "$1 $2")
				colName = colName.replace /_/g, " "
				colName = colName.ucwords()

				config =
					name   : colName
					source : keyName

				updated = true
				DataMap.addColumn tableName, config

			else

				found.deduceColumnType(value)

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

		for source, col of dm.types[tableName].col

			keepColumn = true
			if reduceFunction?
				keepColumn = reduceFunction(col)

			if source.charAt(0) == "_"
				keepColumn = false

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

	##|
	##|  Export a table / return all data as a single object
	##|
	@exportTable: (tableName)=>
		return DataMap.getDataMap().engine.export(tableName)

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
		dm = DataMap.getDataMap()
		if !dm.types[tableName]?
			dm.types[tableName] = new DataSetConfig.Table(tableName)
		doc = dm.engine.set path, newData

		##|
		##|  Remove any cached values that happen to exist
		for varName, value of newData
			delete dm.cachedFormat["/#{tableName}/#{keyValue}/#{varName}"]

		if dm.types[tableName].evWaiting?
			clearTimeout dm.types[tableName].evWaiting

		##|
		##|  Set a timer to let everyone know there is new data
		dm.types[tableName].evWaiting = setTimeout ()=>
			ev = new CustomEvent("new_data", { detail: { tablename: tableName, id: keyValue }})
			window.dispatchEvent ev
			delete dm.types[tableName].evWaiting
		, 10

		return doc

	## -------------------------------------------------------------------------------------------------------------
	## Change an attribute from an active table
	##
	@changeColumnAttribute: (tableName, sourceName, field, newValue, ignoreEvents)=>

		dm = DataMap.getDataMap()
		if !dm.types[tableName]?
			# console.log "Warning: can't changeColumnAttribute for missing table #{tableName}"
			return false

		col = dm.types[tableName].getColumn(sourceName)
		if !col?
			# console.log "Warning: can't changeColumnAttribute for missing table #{tableName} column #{sourceName} (#{field} = #{newValue})"
			return false

		dm.cachedFormat = {}

		if field == "render"
			new ErrorMessageBox("Field 'render' is no longer used, see renderCode, change #{tableName}, source=#{sourceName}, field=#{field} new=#{newValue}")
			return

		##|
		##|  Make the change
		col.changeColumn(field, newValue)

		##|
		##|  Send out events to those that need it unless we aren't sending events.
		##|
		if ignoreEvents? and ignoreEvents == true or !globalTableEvents?
			return true

		##| Send chagne event
		# console.log "changeColumnAttribute #{tableName}, #{sourceName}, #{field}, #{newValue}"
		globalTableEvents.emitEvent "table_change", [ tableName, sourceName, field, newValue ]
		return true

	@addDataUpdateTable: (tableName, keyValue, newData) =>

		path = "/#{tableName}/#{keyValue}"
		# doc = DataMap.getDataMap().engine.set path, newData
		doc = DataMap.getDataMap().engine.setFastDocument tableName, keyValue, newData

		dm = DataMap.getDataMap()
		if !dm.types[tableName]?
			dm.types[tableName] = new DataSetConfig.Table(tableName)

		if typeof newData is "object"
			updated = dm.setDataTypesFromSingleObject tableName, newData 

		##|
		##|  Remove any cached values that happen to exist
		for varName, value of newData
			delete dm.cachedFormat["/#{tableName}/#{keyValue}/#{varName}"]

		if dm.types[tableName].evWaiting?
			clearTimeout dm.types[tableName].evWaiting

		##|
		##|  Set a timer to let everyone know there is new data
		dm.types[tableName].evWaiting = setTimeout ()=>
			ev = new CustomEvent("new_data", { detail: { tablename: tableName, id: keyValue }})
			window.dispatchEvent ev
			delete dm.types[tableName].evWaiting
		, 10

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

	##|
	##|  Delete a key
	@deleteDataForkey: (tableName, keyValue)=>
		console.log "TODO: Not Implemented"

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
		##|  TODO Fix Row Data
		rowData = {}
		if dm.types[tableName]?.col[fieldName]?
			currentValue = dm.types[tableName].col[fieldName].renderValue(currentValue, keyValue, rowData)

		if !currentValue? or currentValue == null
			currentValue = ""

		dm.cachedFormat[path] = currentValue
		return currentValue

	@getCellColor: (tableName, keyValue, fieldName) =>

		column = null
		dm = DataMap.getDataMap()
		if dm.types[tableName]?.col[fieldName]?
			column = dm.types[tableName]?.col[fieldName]
		else
			return null

		if !column.getHasColorFunction? or !column.getHasColorFunction()
			return null

		value = dm.engine.getFast tableName, keyValue, fieldName
		rowData = {}

		colorFunction = column.getColorFunction()
		colorValue = colorFunction(value, keyValue, rowData)

		return colorValue

	@refreshTempTable: (tableName, data, isArray) =>
		tableUpdated = false
		i = 0
		if !isArray
			@removeTableData tableName
			for id, rec of data
				unless typeof rec is "object"
					@addDataUpdateTable tableName, data.id || i++, data
					tableUpdated = true
					break

			if tableUpdated == false
				@importDataFromObjects tableName, data
		else
			@removeTableData tableName
			for rec, id in data
				unless typeof rec is "object"
					@addDataUpdateTable tableName, i++, data
					tableUpdated = true
					break

			if tableUpdated == false
				@importDataFromObjects tableName, data
