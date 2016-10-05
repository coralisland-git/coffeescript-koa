class TableViewCol extends TableViewColBase

	## -------------------------------------------------------------------------------------------------------------
	## constructor create new column object
	##
	## @param [String] name The name of the column
	## @param [String] title The title to show in the header
	##
	constructor : (@tableName)->
		@data = {}

	changeColumn: (varName, value)=>
		if @data[varName] == value then return

		if varName == "render"
			if value? and typeof value != "function"
				console.log "changeColumn ", @data.name, "render=", value
				functionText = DataTypeCollection.renderFunctionToString(value)
				value = DataTypeCollection.renderStringToFunction(functionText)

			@render = value
			return true

		# console.log "changeCol #{varName} to #{value} for #{@getSource()}"
		@data[varName] = value
		delete @formatter
		delete @actualWidth
		return true

	##|
	##|  By default check for a render function defined
	##|  and use that,  if no render function is defined
	##|  then use the formatter if defined.
	renderValue: (value, keyValue, row)=>

		f = @getRenderFunction()
		if f? then return f(value, @tableName, @getSource(), keyValue, row)

		f = @getFormatter()
		if f? then return f.format(value, @getOptions(), @tableName, keyValue)

		return value

	getRenderFunction: ()=>
		if @render? and typeof @render == "function"
			return @render

	##|
	##|  Return the name of the column
	getName: ()=>
		return @data.name

	##|
	##|  Returns the name of the source field in the datamap
	getSource : ()=>
		return @data.source

	getOrder: ()=>
		return @data.order

	getVisible: ()=>
		if @isGrouped?    and @isGrouped == true then return false
		if @data.visible? and @data.visible == true then return true
		if @data.visible? and @data.visible == false then return false
		return true

	getHideable: ()=>
		if @data.hideable? and @data.hideable == true then return true
		return false

	getRequired: ()=>
		if @data.required? and @data.required == true then return true
		return false

	getClickable: ()=>

		if @clickable? and @clickable == true
			return true

		if @clickable? and @clickable == false
			return false

		if @data.clickable? and @data.clickable == true
			return true

		if @data.clickable? and @data.clickable == false
			return false

		f = @getFormatter()
		if f? and f.clickable? and f.clickable == true
			return true

		return false

	getOptions: ()=>
		if @data.options? then return @data.options
		return null

	##|
	##|  returns true if the field is editable
	getEditable: ()=>
		return @data.editable

	##|
	##|  Returns the type in text format
	getType: ()=>
		if @data.type? then return @data.type
		return "text"

	getAlign: ()=>
		if @data.align? and @data.align.length > 0
			return @data.align

		f = @getFormatter()
		if f? and f.align? then return f.align

		return null

	getAutoSize: ()=>
		if @data.autosize? and @data.autosize == true then return true
		width = @getWidth()
		if width? and width > 0 then return false
		return true

	getWidth: ()=>

		if typeof @data.width == "string"
			@data.width = parseInt(@data.width)

		##| if width is 0 then consider as auto width = left padding + max length text width + right padding
		if (@data.width is 0 || @data.width is '0px' || @data.width is "" || !@data.width? )
			f = @getFormatter()
			if f? and f.width? and f.width > 0
				return f.width

			return null

		return @data.width

	## -------------------------------------------------------------------------------------------------------------
	## RenderHeader function to render the header for the column
	##
	## @param [String] extraClassName extra class name that will be included in the th
	## @return [String] html the html for the th
	##
	RenderHeader: (parent, location) =>

		if @visible == false then return

		html = @getName()
		if @sort == -1
			html += "<i class='pull-right fa fa-sort-down'></i>"
		else if @sort == 1
			html += "<i class='pull-right fa fa-sort-up'></i>"

		parent.html html
		parent.addClass "tableHeaderField"

		return parent

	RenderHeaderHorizontal: (parent, location) =>

		if @visible == false then return

		parent.html @getName()
		parent.addClass "tableHeaderFieldHoriz"
		parent.el.css
			"text-align"       : "right"
			"padding-right"    : 8
			"border-right"     : "1px solid #CCCCCC"
			"background-color" : "linear-gradient(to right, #fff, #f2f2f2);"

		@sort    = 0

		return parent

	UpdateSortIcon: (newSort) =>

		@sort = newSort
		@tagSort.removeClass "fa-sort"
		@tagSort.removeClass "fa-sort-up"
		@tagSort.removeClass "fa-sort-down"

		if @sort == -1
			@tagSort.addClass "fa-sort-down"
		else if @sort == 0
			@tagSort.addClass "fa-sort"
		else if @sort == 1
			@tagSort.addClass "fa-sort-up"

		true


	##|
	##|  Called once when the column is created to see if the
	##|  class wants to update the information on the column type
	deduceInitialColumnType: ()=>

		reYear     = /year/i
		reDistance = /distance/i

		@data.skipDeduce = false
		@data.deduceAttempts = 0
		@data.foundOnlyNumbers = true

		if reYear.test @data.name
			@changeColumn "type", "int"
			@changeColumn "options", '####'
			@changeColumn "width", 50
			@changeColumn "align", "right"
			@data.skipDeduce = true
			return

		if reDistance.test @data.name
			@changeColumn "type", "distance"
			@changeColumn "width", 60
			@changeColumn "align", "right"
			@data.skipDeduce = true
			return

		if @data.name == "id"
			@changeColumn "type", "text"
			@changeColumn "width", null
			@changeColumn "visible", false
			@changeColumn "align", "left"
			@changeColumn "name", "ID"
			return

		if @data.source == "lat" or @data.source == "lon"
			@changeColumn "type", "decimal"
			@changeColumn "width", 60
			@changeColumn "visible", true
			@changeColumn "align", "right"
			@changeColumn "options", '#.#####'
			return

		return

	##|
	##|  Given some new data, see if we need to automatically change
	##|  the data type on this column.
	deduceColumnType: (newData)=>

		if @data.skipDeduce? and @data.skipDeduce == true then return null
		if @data.deduceAttempts++ > 50 then return null
		if !newData? then return null
		if @data.type != "text" then return null

		if typeof newData == "string"

			if reDate1.test newData
				# console.log "Match reDate1:", newData
				@changeColumn "type", "timeago"
				@changeColumn "width", 80
				@data.skipDeduce = true
				return

			if reDate2.test newData
				# console.log "Match reDate2:", newData
				@changeColumn "type", "timeago"
				@changeColumn "width", 110
				@data.skipDeduce = true
				true

			# console.log "name=", @data.name, "newdata=", newData, typeof newData, @data.skipDeduce

			if /^https*/.test newData
				@changeColumn "type", "link"
				@changeColumn "align", "center"
				@changeColumn "width", 80
				@data.skipDeduce = true
				return true

			if /^ftp*:/.test newData
				@changeColumn "type", "link"
				@changeColumn "align", "center"
				@changeColumn "width", 80
				@data.skipDeduce = true
				return true

			if @data.foundOnlyNumbers and reNumber.test newData
				@changeColumn "type", "int"
				@changeColumn "width", 80
				return

			if @data.foundOnlyNumbers and reDecimal.test newData
				@changeColumn "type", "decimal"
				@changeColumn "width", 100
				return

			if @data.foundOnlyNumbers
				@changeColumn "type", "text"
				@data.foundOnlyNumbers = false

		else if typeof newData == "number"

			if @data.foundOnlyNumbers
				@changeColumn "type", "int"
				@changeColumn "align", "right"
				@changeColumn "width", 80

		else if typeof newData == "boolean"

			@changeColumn "type", "boolean"
			@changeColumn "width", 60
			@data.skipDeduce = true
			return true

		else if typeof newData == "object"

			@changeColumn "type", "simpleobject"
			@changeColumn "width", null
			@data.skipDeduce = true
			return true

		return null

