##|
##|  Universal class to translate from one value to another that
##|  is designed to be human readable
##|

# create a namespace to export our public methods
root = exports ? this
root.DataFormatter = class DataFormatter

	##|
	##| Output:  Suggested width of the data to display in pixels
	formats: {}

	##|
	##|  Given a string, return a number
	@getNumber: (data) =>
		if !data? then return 0
		if typeof data == "number" then return data
		result = data.toString().replace /[^0-9\.\-]/g, ""
		result = parseFloat result

	##|
	##| Given a date in a human readable form, parse it and return the Moment
	##| object (see momentjs) that represents the date/time.
	##|
	##| @param [string] date The date string to parse
	##|
	##| @note returns null if the date is invalid
	##|
	@getMoment: (data) =>

		if !data? then return null

		if data? and data._isAMomentObject? and data._isAMomentObject
			return data

		if typeof date != "string"
			return moment(data)

		if date.match /\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d/
			return moment(date, "YYYY-MM-DD HH:mm:ss")

		if date.match /\d\d\d\d.\d\d.\d\d/
			return moment(date, "YYYY-MM-DD")

		if date.match /\d\d-\d\d-\d\d\d\d/
			return moment(date, "MM-DD-YYYY")

		return null;

	register: (formattingClass) =>

		@formats[formattingClass.name] = formattingClass

	getFormatter: (dataType) =>

		if !@formats[dataType]
			console.log "Registered types:", @formats
			throw new Error("Invalid type: " + dataType)

		return @formats[dataType]


	##|
	##|  Format some data based on the type and
	##|  return just the formatted value, not the style or other details.
	##|
	formatData: (dataType, data, options, path) =>

		if !@formats[dataType]?
			console.log "Registered types:", @formats
			return "Invalid type [#{dataType}]"

		value = @formats[dataType].format data, options, path

	##|
	##|  Convert visual data into a storable raw format
	unformatData: (dataType, data, options, path) =>

		if !@formats[dataType]? then return "Invalid type [#{dataType}]"
		value = @formats[dataType].unformat data, options, path


	constructor: () ->


class DataFormatterType

	name          : 	""
	width         : null
	editorShowing : false
	editorPath    : ""

	##|
	##|  Text to add to the css for displaying
	styleFormat: ""

	format: (data, options, path) =>
		return null

	unformat: (data, path) =>
		return null

	allowKey: (keyCode) =>
		return true

	##|
	##|  Start editing an element
	editData: (parentElement, currentValue, path, @onSaveCallback) =>

		left     = 0
		top      = 0
		width    = 100
		height   = 40
		elParent = null

		@editorPath = path

		if parentElement?

			elParent = $(parentElement)
			pos      = elParent.position()
			left     = pos.left
			top      = pos.top
			width	 = elParent.outerWidth(false)
			height	 = elParent.outerHeight(false)

		@editorShowing = true
		@openEditor(elParent, left, top, width, height, currentValue, path)

	saveValue: (newValue) =>

		console.log "Saving value", newValue
		if @onSaveCallback?
			@onSaveCallback @editorPath, newValue
		true

	appendEditor: () =>

		$("body").append(@elEditor)

		@elEditor.on "blur", (e) =>
			if @editorShowing
				@editorShowing = false
				e.preventDefault()
				e.stopPropagation()
				@elEditor.hide()
				return true
			return false

		##|
		##|  Close the popup with the escape key
		@elEditor.on "keydown", (e) =>
			if e.keyCode == 13
				@saveValue(@elEditor.val())
				@editorShowing = false
				e.preventDefault()
				e.stopPropagation()
				@elEditor.hide()
				return false

			if e.keyCode == 27
				@editorShowing = false
				e.preventDefault()
				e.stopPropagation()
				@elEditor.hide()
				return false

			if @allowKey e.keyCode
				return true
			else
				return false

		$("document").on "click", (e) =>
			console.log "Click"


	##|
	##|  Open the dynamic text editor
	openEditor: (elParent, left, top, width, height, currentValue, path) =>

		if !@elEditor
			@elEditor = $ "<input />",
				type: "text"
				class: "dynamic_edit"

			@appendEditor()

		@elEditor.css
			position  : "absolute"
			"z-index" : 5001
			top       : top
			left      : left
			width     : width
			height    : height

		@elEditor.val currentValue

		@elEditor.show()
		@elEditor.focus()


class DataFormatText extends DataFormatterType

	name: "text"

	format: (data, options, path) =>

		if !data?
			return ""

		return data

	unformat: (data, path) =>

		return data

class DataFormatInt extends DataFormatterType

	name: "int"

	format: (data, options, path) =>
		return numeral(DataFormatter.getNumber data).format("#,###")

	unformat: (data, path) =>
		return DataFormatter.getNumber data

class DataFormatNumber extends DataFormatterType

	name: "number"

	format: (data, options, path) =>
		return numeral(DataFormatter.getNumber data).format("#,###.[##]")

	unformat: (data, path) =>
		return DataFormatter.getNumber data

class DataFormatFloat extends DataFormatterType

	name: "decimal"

	allowKey: (keyCode) =>
		return true

		if keyCode >= 48 and keyCode <= 57 then return true
		if keyCode >= 96 and keyCode <= 105 then return true
		if keyCode == 190 then return true
		if keyCode == 189 then return true
		if keyCode == 119 then return true
		if keyCode == 109 then return true
		console.log "Rejecting key:", keyCode
		return false

	format: (data, options, path) =>
		return numeral(DataFormatter.getNumber data).format("#,###.##")

	unformat: (data, path) =>
		return DataFormatter.getNumber data

class DataFormatCurrency extends DataFormatterType

	name: "money"

	format: (data, options, path) =>
		return numeral(DataFormatter.getNumber data).format('$ #,###.[##]')

	unformat: (data, path) =>
		return DataFormatter.getNumber data

class DataFormatPercent extends DataFormatterType

	name: "percent"

	format: (data, options, path) =>
		return numeral(DataFormatter.getNumber data).format('#,###.[##] %')

	unformat: (data, path) =>
		return DataFormatter.getNumber data/100.0

class DataFormatDate extends DataFormatterType

	name: "date"
	width: 65

	format: (data, options, path) =>
		m = DataFormatter.getMoment data
		if !m? then return ""
		return m.format "MM/DD/YYYY"

	unformat: (data, path) =>
		m = DataFormatter.getMoment data
		if !m? then return ""
		return m.format "YYYY-MM-DD HH:mm:ss"

class DataFormatDateTime extends DataFormatterType

	name: "datetime"

	openEditor: (elParent, left, top, width, height, currentValue, path) =>

		##|
		##|  Show a popup menu
        @picker = new PopupMenuCalendar currentValue, top, left
        @picker.onChange = (newValue) =>
            @recordChange @name, newValue
		true

	format: (data, options, path) =>
		m = DataFormatter.getMoment data
		if !m? then return ""
		return m.format "ddd, MMM Do, YYYY h:mm:ss a"

	unformat: (data, path) =>
		m = DataFormatter.getMoment data
		if !m? then return ""
		return m.format "YYYY-MM-DD HH:mm:ss"

class DataFormatDateAge extends DataFormatterType

	name: "age"
	width: 135

	format: (data, options, path) =>
		m = DataFormatter.getMoment data
		if !m? then return "&mdash;"

		html = "<span class='fdate'>" + m.format("MM/DD/YYYY") + "</span>"
		age = moment().diff m
		age = age / 86400000

		if (age < 401)
			age = numeral(age).format("#") + " d"
		else if (age < 365 * 2)
			age = numeral(age / 30.5).format("#") + " mn"
		else
			age = numeral(age / 365).format("#.#") + " yrs"

		html += "<span class='fage'>" + age + "</span>"
		return html

	unformat: (data, path) =>
		m = DataFormatter.getMoment data
		if !m? then return ""
		return m.format "YYYY-MM-DD HH:mm:ss"

class DataFormatEnum extends DataFormatterType

	name: "enum"

	openEditor: (elParent, left, top, width, height, currentValue, path) =>

		##|
		##|  Show a popup menu
		p = new PopupMenu "Options", left, top
		if typeof @options == "object" and typeof @options.length == "number"
			for i, o of @options
				# console.log "Adding[", i, "][", o, "]"
				p.addItem o, (coords, data) =>
					# console.log "Saving[", data, "]"
					@saveValue data
				, o
		else
			console.log "Invalid options: ", @options

		true

	##|
	##| In this case, the options is an array or a comma seperated list of values
	##| data must be one of those values of a numeric index to those values.
	format: (data, @options, path) =>

		if typeof @options == "string"
			@options = @options.split /\s*,\s*/

		if !data?
			return "&mdash;"

		for i, o of @options
			if data == o then return o

		for i, o of @options
			if "#{data}" == "#{i}" then return o

		return "[" + data + "]"

	unformat: (data, path) =>
		return data

class DataFormatDistance extends DataFormatterType

	name: "distance"
	width: 80

	##|
	##| Takes meters in, returns a formatted string
	format: (data, options, path) =>
		val = DataFormatter.getNumber data
		ft = 3280.8 * val
		if (ft < 1000) then return numeral(ft).format("#,###") + " ft."
		mi = 0.621371 * val
		return numeral(mi).format("#,###.##") + " mi.";

	unformat: (data, path) =>
		val = DataFormatter.getNumber(data)
		return val * 3280.8

class DataFormatBoolean extends DataFormatterType

	name: "boolean"
	width: 40

	##|
	##| Takes meters in, returns a formatted string
	format: (data, options, path) =>
		if !data? then return "No"
		if data == null or data == 0 then return "No"
		return "Yes"

	unformat: (data, path) =>
		if !data? then return 0
		if data == null or data == 0 then return 0
		if data == "No" or data == "no" or data == "false" or data == "off" then return 0
		return 1

class DataFormatTimeAgo extends DataFormatterType

	name: "timeago"
	width: 135

	format: (data, options, path) =>
		stamp = DataFormatter.getMoment data
		if stamp == null
			if val then return val
			return "&mdash;"

		age  = moment().diff(stamp) / 1000
		if age < 60
			txt = numeral(age).format("#") + " sec"
		else if age < (60 * 60)
			txt = numeral(age/60).format("#") + " min"
		else if age > 86400
			days = Math.floor(age / 86400)
			hrs  = Math.floor((age - (days * 86400)) / (60 * 60))
			if days != 1 then daysTxt = "days" else daysTxt = "day"
			if hrs > 0
				txt = "#{days} #{daysTxt}, #{hrs} hr"
				if hrs != 1 then txt += "s"
			else
				txt = "#{days} #{daysTxt}"
		else
			hrs = Math.floor(age / (60 * 60))
			min = (age - (hrs * 60 * 60)) / 60
			if hrs > 1 then hrsText = "hrs" else hrsText = "hr"
			txt = numeral(hrs).format("#") + " #{hrsText}, " + numeral(min).format("#") + " min";

		return txt

	unformat: (data, path) =>
		m = DataFormatter.getMoment data
		if !m? then return ""
		return m.format "YYYY-MM-DD HH:mm:ss"


try
	globalDataFormatter = new DataFormatter()

	globalDataFormatter.register(new DataFormatText())
	globalDataFormatter.register(new DataFormatInt())
	globalDataFormatter.register(new DataFormatNumber())
	globalDataFormatter.register(new DataFormatFloat())
	globalDataFormatter.register(new DataFormatCurrency())
	globalDataFormatter.register(new DataFormatDate())
	globalDataFormatter.register(new DataFormatDateTime())
	globalDataFormatter.register(new DataFormatDateAge())
	globalDataFormatter.register(new DataFormatEnum())
	globalDataFormatter.register(new DataFormatDistance())
	globalDataFormatter.register(new DataFormatBoolean())
	globalDataFormatter.register(new DataFormatPercent())
	globalDataFormatter.register(new DataFormatTimeAgo())

catch e
	console.log "Exception while registering global Data Formatter:", e


globalOpenEditor = (e) ->
    ##|
    ##|  Clicked on an editable field
    path = $(e).attr("data-path")
    DataMap.getDataMap().editValue path, e
    false


root = exports ? this
class DataMap

    constructor: ()->

        @data  = {}
        @types = {}

    ##|
    ##|  Returns a global instance of the data map
    @getDataMap: () =>
        if !root.globalDataMap
            root.globalDataMap = new DataMap()

        return root.globalDataMap

    ##|
    ##|  Set the data type for a given type of data
    ##|  Called statically to
    @setDataTypes: (tableName, columns) =>

        dm = DataMap.getDataMap()

        if !dm.types[tableName]?
            dm.types[tableName] = new DataTypeCollection(tableName)

        dm.types[tableName].configureColumns columns
        true

    ##|
    ##|  Return the columns associated with a given table
    ##|  reduceFunction is called with every table name,
    ##|  and return the columns that return true.
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
        formatter.editData el, existingValue, path, @updatePathValue
        true

    updatePathValue: (path, newValue) =>

        ##| Split the path name
        ##| ["", "zipcode", "03105", "lon"]
        parts = path.split '/'
        tableName = parts[1]
        keyValue  = parts[2]
        fieldName = parts[3]

        existingValue = @data[tableName][keyValue][fieldName]
        console.log "Compare ", existingValue, " to ", newValue
        if existingValue == newValue then return true
        @data[tableName][keyValue][fieldName] = newValue

        result = $("[data-path='#{path}']")
        if result.length > 0

            currentValue = newValue

            if @types[tableName]? and @types[tableName].col[fieldName]?
                formatter    = @types[tableName].col[fieldName].formatter
                currentValue = formatter.format currentValue, @types[tableName].col[fieldName].options, path

            result.html currentValue
            .addClass "dataChanged"

        true

    @addData: (tableName, keyValue, values) =>

        dm = DataMap.getDataMap()

        # console.log "addData[", tableName, "][", keyValue, "][", values ,"]"

        if !dm.data[tableName]
            dm.data[tableName] = {}

        if !dm.data[tableName][keyValue]
            ##|
            ##|  Entirely new value, don't check for updates
            dm.data[tableName][keyValue] = values
            return true

        for varName, value of values
            path = "/#{tableName}/#{keyValue}/#{varName}"
            dm.updatePathValue path, value

        true

    @getDataField: (tableName, keyValue, fieldName) =>

        dm = DataMap.getDataMap()
        if !dm.data[tableName]? or !dm.data[tableName][keyValue]?
            return ""
        return dm.data[tableName][keyValue][fieldName]

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
                className += " " + formatter.name

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
##|
##|  A list of data types that go together such as columns in a table
##|  or database columns.   The configName part of the constructor is used
##|  to save or load the configuration if needed
##|

class DataType

    source        : ''       ##| Data source to copy from
    visible       : false    ##| Visible (Used for tables)
    editable      : false    ##| Editable (Inline edit for display)
    hideable      : true     ##| Can be hidden
    required      : false    ##| Used to create a new record
    type          : ''       ##| Data type text
    tooltip       : ''       ##| Tooltip text
    formatter     : null
    displayFormat : null

    constructor: () ->

class DataTypeCollection

    constructor: (@configName, cols) ->

        @col = {}
        @colList = []
        if cols? then @configureColumns cols

    ##|
    ##|  Given an array of column configuration structures, create new
    ##|  columns automatically based on the configuration.
    ##|  Example:
    ##|
    ##|  name       : 'Create Date'
    ##|  source     : 'create_date'
    ##|  visible    : true
    ##|  hideable   : true
    ##|  editable   : true
    ##|  type       : 'datetime'
    ##|  required   : false
    ##|
    configureColumn: (col) =>

        c = new DataType()

        for name, value of col
            c[name] = value

        ##|
        ##|  Allocate the data formatter
        c.formatter = globalDataFormatter.getFormatter col.type
        c.extraClassName = "col_" + @configName + "_" + col.source

        ##|
        ##| Optional render function on the column
        if typeof col.render == "function"
            c.displayFormat = col.render

        @col[c.source] = c
        @colList.push(c.source)


    ##|
    ##|  Same as configureColumn but allows and array to be passed in
    ##|
    configureColumns: (columns) =>

        for col in columns
            @configureColumn(col)

        ##|
        ##|  See if there is any CSS to inject

        css = ""
        for i, col of @col

            str = ""
            if col.width? and col.width
                str += "width : #{col.width}px; "
            if col.align? and col.align
                str += "text-align : " + col.align

            if str and str.length > 0
                css += "." + col.extraClassName + " {"
                css += str
                css += "}\n"

        if css
            $("head").append "<style type='text/css'>\n" + css + "\n</style>"

        # $('head').append('<style type="text/css">body{font:normal 14pt Ar

        true




class DataMapper

	constructor: () ->
		##

class DataMapperBuilder

	deserialize: (txt) =>

		try
			@mapData = JSON.parse txt
		catch e
			##|  ignore parse errors
			console.log "DataMapperBuilder, deserialize: ", e

		@redrawDataTypes()

		setTimeout ()=>
			# @addTransformRule('GF20030226223929852543000000','transform','asdf','asdfadsf');
			console.log "test"
			# @serialize()
		, 1500

	serialize: () =>
		text = JSON.stringify(@mapData)
		console.log "TEXT=", text

	##|
	##|  Add a transformation rule to a given field
	##|  if that rule already exists, update it.
	addTransformRule: (clickName, ruleType, pattern, dest) =>

		console.log "addTransformRule('#{clickName}','#{ruleType}','#{pattern}','#{dest}');"

		##|
		##|  Add the new rule under the "transform" array
		##|

		if !@mapData[clickName]? then return
		if !@mapData[clickName].transform?
			@mapData[clickName].transform = []

		for t in @mapData[clickName].transform
			if t.type == ruleType and t.pattern == pattern
				t.dest = dest
				@redrawDataTypes()
				return true

		##|
		##|  Create a new rule
		@mapData[clickName].transform.push
			type    : ruleType
			pattern : pattern
			dest    : dest

		@redrawDataTypes()
		true


	##|
	##|  Click the + sign to add a rule to an item
	onClickMapPlus: (e) =>

		e.stopPropagation()
		e.preventDefault()

		clickName = $(e.currentTarget).attr("box_name")

		console.log "CURRENT:", @mapData[clickName]

		for idx, dataType of @KnownFields.colList
			if dataType.name == @mapData[clickName].mapName
				console.log "KNOWN  :", dataType

		m = new ModalDialog
			showOnCreate: false
			content:      "Add a custom processing rule, mapping to field: "
			position:     "top"
			title:        "Custom Rule"
			ok:           "Save"

		m.getForm().addTextInput "pattern",     "Target Pattern"
		m.getForm().addTextInput "destination", "Map To"

		m.getForm().onSubmit = (form) =>
			##|
			##|  Add a new type of mapping rule
			console.log "Form=", form
			@addTransformRule clickName, "transform", form.pattern, form.destination
			true

		m.show()

	onClickMap: (e) =>

		e.stopPropagation()
		e.preventDefault()

		clickName = $(e.currentTarget).attr("box_name")

		##|
		##|  Grab a reference to the row that was selected
		elBox = @SourceFields[clickName]

		##|
		##|  Create the popup menu
		pop = new PopupMenu "Map '#{clickName}'", e
		pop.resize(400)

		pop.addItem "Edit Target", (e, info) =>
			@onSelectEdit clickName

		for idx, dataType of @KnownFields.colList

			if dataType.isSelected? and dataType.isSelected

				pop.addItem "Copy to " + dataType.name, (e, info) =>
					@onSelectMap info, clickName, "copy"
				, idx

				pop.addItem "Append to " + dataType.name, (e, info) =>
					@onSelectMap info, clickName, "append"
				, idx

	onSelectEdit: (clickName) =>

		m = new ModalDialog
			showOnCreate: false
			content:      "Type a field name or custom field"
			position:     "top"
			title:        "Field Mapping"
			ok:           "Save"

		fieldNames = []
		for idx, dataType of @KnownFields.colList
			fieldNames.push dataType.name

		m.getForm().addTextInput "dest", "Target Field"
		.makeTypeahead fieldNames

		m.getForm().onSubmit = (form) =>
			console.log "Submitted form, test value=", form.dest
			for idx, dataType of @KnownFields.colList
				if form.dest == dataType.name
					dataType.mapdata.mapType = "copy"
					dataType.mapdata.mapSource = clickName
					@mapData[clickName] =
						mapType: "copy"
						mapSource: clickName
						mapDest: dataType.source
						mapName: dataType.name
					@redrawDataTypes()
					m.hide()
					return

			@mapData[clickName] =
				mapType: "formula"
				mapSource: clickName
				mapDest: form.dest
				mapName: null
			@redrawDataTypes()

			m.hide()

		m.show()

	onSelectMap: (idx, clickName, action) =>

		delete @KnownFields.colList[idx].isSelected
		@KnownFields.colList[idx].el.removeClass "selected"

		@KnownFields.colList[idx].mapdata.mapType = action
		@KnownFields.colList[idx].mapdata.mapSource = clickName

		@mapData[clickName] =
			mapType: action
			mapSource: clickName
			mapDest: @KnownFields.colList[idx].source
			mapName: @KnownFields.colList[idx].name

		@redrawDataTypes()
		console.log "MAP=", @mapData

	##|
	##|  When someone clicks on one of the known map sources on the
	##|  right, mark it as selected and remove the selection mark from
	##|  all the other possible sources.
	onSelectDatatype: (e) =>
		e.stopPropagation()
		e.preventDefault()

		idx = $(e.currentTarget).attr("idx")

		if @KnownFields.colList[idx].isSelected?
			console.log "Remove ", idx
			@KnownFields.colList[idx].el.removeClass "selected"
			delete @KnownFields.colList[idx].isSelected
		else
			console.log "Set ", idx
			@KnownFields.colList[idx].el.addClass "selected"
			@KnownFields.colList[idx].isSelected = true

		# @removeAllSelected(idx)

	##|
	##|  Deselect any selected indexs on the right
	removeAllSelected: (exceptedIndex) =>

		##|
		##|  Remove other selected
		for idx, dataType of @KnownFields.colList
			if idx != exceptedIndex and dataType.isSelected? and dataType.isSelected
				dataType.el.removeClass "selected"
				delete dataType.isSelected

	redrawTransformRules: (name, field) =>

		if !@mapData[name].transform? then return false
		for t in @mapData[name].transform

			if !field.elTransformTable?
				td = $ "<td colspan='2' />"
				field.elTransformTable = $ "<table class='transformRuleTable' />"
				td.append field.elTransformTable
				field.elTransform.append td
				field.elTransfromElements = {}

			if !field.elTransfromElements[t.name]?

				row = $ @templateRuleLine(t)
				field.elTransfromElements[t.name] = field.elTransformTable.append row

	redrawDataTypes: () =>

		##
		for idx, dataType of @KnownFields.col

			found = false
			# dataType = @KnownFields.col[dataTypeName]
			for i, mapdata of @mapData

				if mapdata.mapName == dataType.name

					if mapdata.mapType == "copy"
						dataType.el.find("i").addClass "fa-tag"
						dataType.el.addClass "assigned"
						found = true
					else if mapdata.mapType == "append"
						dataType.el.find("i").addClass "fa-copy"
						dataType.el.addClass "assigned"
						found = true

			if not found
				dataType.el.find("i").removeClass "fa-tag"
				dataType.el.find("i").removeClass "fa-copy"
				dataType.el.removeClass "assigned"


		for name, field of @SourceFields
			found = true
			if @mapData[name]? and @mapData[name].mapType == "copy"
				field.mapBox.html "<i class='fa fa-fw fa-tag'/> Copy to " + @mapData[name].mapDest
				field.el.children().addClass "assigned"
				@redrawTransformRules name, field
			else if @mapData[name]? and @mapData[name].mapType == "append"
				field.mapBox.html "<i class='fa fa-fw fa-copy'/> Append to " + @mapData[name].mapDest
				field.el.children().addClass "assigned"
				@redrawTransformRules name, field
			else if @mapData[name]? and @mapData[name].mapType == "formula"
				field.mapBox.html "<i class='fa fa-fw fa-arrow-right'/> Custom to " + @mapData[name].mapDest
				field.el.children().addClass "assigned"
				@redrawTransformRules name, field
			else
				found = false
				field.mapBox.html "<i class='fa fa-fw'/> None"
				field.el.children().removeClass "assigned"

			if found
				field.mapBoxPlus.show()
			else
				field.mapBoxPlus.hide()

		@serialize()
		true

	##|
	##|  Create the data in each field that holds the map configuration
	setupKnownFields: () =>

		for idx, dataType of @KnownFields.colList
			dataType.mapdata =
				mapType : "none"


	constructor: (sourceObj, knownFields, holder) ->

		##
		try

			@mapData      = {}
			@SourceFields = {}
			@KnownFields  = knownFields

			@elMain = $(holder).append "<table class='dataMapperMain' />"
			@elMain.css
				width    : "100%"

			codes = (k for k of sourceObj)
			correctOrder = codes.sort (a, b) ->
				if sourceObj[a] and not sourceObj[b] then return -1
				if sourceObj[b] and not sourceObj[a] then return 1
				if a.toUpperCase() < b.toUpperCase() then return -1
				if a.toUpperCase() > b.toUpperCase() then return 1
				return 0

			@setupKnownFields();

			@templateRuleLine = Handlebars.compile '''
				<tr>
				<td class='ruleType'> {{type}} </td>
				<td class='rulePattern'> {{pattern}} </td>
				<td class='ruleDest'> {{dest}} </td>
				<td class='ruleMinus'> <i class='fa fa-minus' /> </td>
				</tr>
			'''

			yPos = 0
			for name in correctOrder
				value = sourceObj[name]

				label = $ "<label />",
					html: name

				sampleData = $ "<div />",
					html: value
					class: "data"

				elBox = {}
				elBox.name = name
				elBox.value = value
				elBox.el = $ "<tr />",
					id       : "builder_#{name}"
					class	 : "mapColumn"

				elBox.mapBox = $ "<td />",
					class    : "mapBox"
					html     : "None"
					box_name : name

				elBox.mapBoxPlus = $ "<td />",
					class    : "mapBoxPlus"
					html     : "<i class='fa fa-fw fa-plus' />"
					box_name : name

				elBox.mapBox.on 'click', @onClickMap

				elBox.mapBoxPlus.on 'click', @onClickMapPlus

				elBox.el.append label
				elBox.el.append sampleData
				elBox.el.append elBox.mapBox
				elBox.el.append elBox.mapBoxPlus

				elBox.el.css
					padding         : "4px"
					backgroundColor : "#eeeeee"

				@SourceFields[name] = elBox

				##|
				##|  Transform rules
				elBox.elTransform = $ "<tr />",
					id: "tr_#{name}"
					class: "transformRules"

				@elMain.append elBox.el
				@elMain.append elBox.elTransform
				yPos += 44

			##|
			##|  List of known fields on the right

			elKnown = $ "<div />",
				id: "knownColumns"
				class: "knownColumns"

			elKnown.append $ "<div />",
				class: "knownTitle"
				html: "Mappable Columns"

			for idx, dataTypeName of @KnownFields.colList

				dataType = @KnownFields.col[dataTypeName]
				el = $ "<div />",
					class:   "knownItem"
					popname: dataType.source
					idx:     idx
					html:    "<i class='fa fa-fw' /> " + dataType.name

				el.on "click", @onSelectDatatype

				dataType.el = el
				elKnown.append el

			@elMain.append elKnown
			@redrawDataTypes();

			##|
			##|  Fix the width
			w = @elMain.width()
			@elMain.css "width", w-240

		catch e
			console.log "Exception in DataMapperBuilder: ", e, e.stack
###

This class represents one set of data which means

    b)  A source for the data

###

root = exports ? this
root.DataSet = class DataSet

    ##|
    ##|  Create a new data set
    ##|  param @baseName - The name for this data set, used to map the set to a database
    constructor : (@baseName)->

        @data       = {}
        @useDataMap = true


    setAjaxSource: (url, @subElement, @keyElement) =>

        @dataSourceType = "ajax"
        @dataSourceUrl  = url
        true


    ##|
    ##|  Returns a promise that loads the data
    doLoadData: () =>

        new Promise (resolve, reject) =>

            if @dataSourceType == "ajax"

                ##|
                ##|  Load Ajax Data
                $.ajax

                    url: @dataSourceUrl

                .done (rawData) =>

                    if @subElement? and @subElement
                        rawData = rawData[@subElement]

                    ##|
                    ##|  Access the global data map
                    if @useDataMap
                        dm = DataMap.getDataMap()

                    for i, o of rawData

                        if @keyElement?
                            key = o[@keyElement]
                        else
                            key = i

                        if @useDataMap
                            DataMap.addData @baseName, key, o
                        else
                            @data[key] = o

                    resolve(this)

                .fail (e) =>

                    reject(e)

            else

                reject new Error "Unknown "








class BusyDialog

    content:       "Processing please wait"
    showing:       false
    busyStack:     []
    callbackStack: []

    constructor:  () ->

        @template = Handlebars.compile '''
        <div class="hidex" id="pleaseWaitDialog">
            <div class="modal-header">
                <h1 id='pleaseWaitDialogTitle'>{{content}}</h1>
            </div>
            <div class="modal-body">
                <div class="progress progress-striped active">
                    <div class="bar" style="width: 100%;"></div>
                </div>
            </div>
        </div>
        '''

        @pleaseWaitHolder = $("body").append @template(this)
        @elTitle          = $("#pleaseWaitDialogTitle")

        @modal = $("#pleaseWaitDialog")
        @modal.hide()

    finished: () =>
        @busyStack.pop()
        if @busyStack.length > 0
            @elTitle.html @busyStack[@busyStack.length-1]
        else
            @modal.hide()
            @showing = false

    exec: (strText, callbackFunction) =>

        @callbackStack.push callbackFunction
        setTimeout () =>
            @showBusy(strText)

            setTimeout () =>
                callbackFunction = @callbackStack.pop()
                if callbackFunction?
                    callbackFunction()
                else
                    console.log "SHOULD NOT BE NULL:", strText, @callbackStack

                @finished()
            , 500

        , 0

    showBusy: (strText, options) =>

        @busyStack.push strText

        ##
        ##  Possibly overwrite default options
        if typeof options == "object"
            for name, val of options
                this[name] = val

        ##|
        ##|  Update the text if already showing
        if @showing
            console.log "Updating to ", strText
            $("#pleaseWaitDialogTitle").html(strText)
            return

        ##|
        ##|  Create the new html
        @showing = true
        @elTitle.html strText

        @show
            position: "center"

    show: (options) =>

        @modal.show()
        @modal.css
            'position' : "fixed"
            left  : () =>
                ($(window).width() - @modal.width()) / 2
            'top' : () =>
                Math.max(0, ($(window).scrollTop() + ($(window).height() - @modal.height()) / 2 ))


$ ->

    window.globalBusyDialog = new BusyDialog()

substringMatcher = (strs) ->
	return (q, cb) ->
		matches = []
		substrRegex = new RegExp(q, 'i')
		for o in strs
			if substrRegex.test o
				matches.push o
		cb matches

class FormField

	constructor: (@fieldName, @label, @type) ->
		@html = @getHtml()

	getHtml: () =>
		return "<input name='#{@fieldName}' id='#{@fieldName}' type='#{@type}' class='form-control' />"

	makeTypeahead: (options) =>
		@typeaheadOptions = options

	onPressEnter: () =>
		## do nothing

	onPressEscape: () =>
		## do nothing

	onAfterShow: () =>

		if @typeaheadOptions?
			@el.addClass ".typeahead"
			@el.typeahead
				hint: true
				highlight: true
				minLength: 1
			,
				name: 'options'
				source: substringMatcher(@typeaheadOptions)

			@el.bind "typeahead:select", (ev, suggestion) =>
				console.log "DID CHANGE:", suggestion

			@el.bind "keypress", (e) =>
				if e.keyCode == 13
					@onPressEnter(e)
					return false

				if e.keyCode == 27
					@onPressEscape(e)
					return false

				return true


class FormWrapper

	constructor: () ->
		@fields = []
		@gid    = "form" + GlobalValueManager.NextGlobalID()

		@templateFormFieldText = Handlebars.compile '''
			<div class="form-group">
				<label for="{{fieldName}}"> {{label}} </label>
				<input class="form-control" id="{{fieldName}}" name="{{fieldName}}">
				<br>
				<div id="{{fieldName}}error" class="text-danger"></div>
			</div>
		'''

	##|
	##|  Add a text input field
	addTextInput: (fieldName, label, fnValidate) =>

		field = new FormField(fieldName, label, "text")
		@fields.push(field)
		return field

	##|
	##|  Generate HTML
	getHtml: () =>

		content = "<form id='#{@gid}'>"

		for field in @fields
			content += @templateFormFieldText(field)

		content += "</form>";

	onSubmit: () =>
		console.log "SUBMIT"

	onSubmitAction: (e) =>
		for field in @fields
			this[field.fieldName] = field.el.val()

		@onSubmit(this)
		if e?
			e.preventDefault()
			e.stopPropagation()

		return false

	onAfterShow: () =>

		@elForm = $("##{@gid}")
		firstField = null
		for field in @fields
			field.el = @elForm.find("##{field.fieldName}")
			field.onAfterShow()
			if !firstField
				firstField = field
				firstField.el.focus()

			field.onPressEnter = (e)=>
				@onSubmitAction(e)

		@elForm.on "submit", @onSubmitAction
		true

class ModalDialog

	content:      "Default content"
	title:        "Default title"
	ok:           "Ok"
	close:        "Close"
	showFooter:   true
	showOnCreate: true
	position:     'top'
	formWrapper:  null

	makeFormDialog: () =>

		@close = "Cancel"

	getForm: () =>

		if !@formWrapper? or !@formWrapper
			@formWrapper = new FormWrapper()

		return @formWrapper

	constructor:  (options) ->

		@gid = GlobalValueManager.NextGlobalID()

		@template = Handlebars.compile '''
			<div class="modal" id="modal{{gid}}" tabindex="-1" role="dialog" aria-hidden="true" style="display: none;">
				<div class="modal-dialog">
					<div class="modal-content">
						<div class="block block-themed block-transparent remove-margin-b">
							<div class="block-header bg-primary-dark">
								<ul class="block-options">
									<li>
										<button data-dismiss="modal" type="button"><i class="si si-close"></i></button>
									</li>
								</ul>
								<h3 class="block-title">{{title}}</h3>
							</div>
							<div class="block-content">
								<p>
								{{{content}}}
								</p>
							</div>
						</div>

						{{#if showFooter}}
						<div class="modal-footer">
							{{#if close}}
							<button class="btn btn-sm btn-default btn1" type="button" data-dismiss="modal">{{close}}</button>
							{{/if}}
							{{#if ok}}
							<button class="btn btn-sm btn-primary btn2" type="button" data-dismiss="modal"><i class="fa fa-check"></i> {{ok}}</button>
							{{/if}}
						</div>
						{{/if}}

					</div>
				</div>
			</div>
		'''

		##
		##  Possibly overwrite default options
		if typeof options == "object"
			for name, val of options
				this[name] = val

		if @showOnCreate
			@show()

	onClose: () =>
		true

	onButton1: () =>
		console.log "Default on button 1"
		@hide();
		true

	onButton2: (e) =>
		if @formWrapper?
			@formWrapper.onSubmitAction(e)
		else
			console.log "Default on button 2"

		@hide();
		true

	hide: () =>
		@modal.modal('hide')

	show: (options) =>

		if @formWrapper?
			@content += @formWrapper.getHtml()

		html = @template(this)
		$("body").append html

		@modal = $("#modal#{@gid}")
		@modal.modal(options)
		@modal.on "hidden.bs.modal", () =>
			##|
			##|  Remove HTML from body
			@modal.remove()

			##|
			##|  Call the close event
			@onClose()

		@modal.find(".btn1").bind "click", () =>
			@onButton1()

		@modal.find(".btn2").bind "click", (e) =>
			e.preventDefault()
			e.stopPropagation()

			options = {}
			@modal.find("input").each (idx, el) =>
				name = $(el).attr("name")
				val  = $(el).val()
				options[name] = val

			if @onButton2(e, options) == true
				@onClose()

			true

		##|
		##| -------------------------------- Position of the dialog ---------------------------

		if @position == "center"

			@modal.css
				'margin-top' : () =>
					Math.max(0, ($(window).scrollTop() + ($(window).height() - @modal.height()) / 2 ))

		if @formWrapper?
			setTimeout ()=>
				@formWrapper.onAfterShow()
			, 10

class ModalMessageBox extends ModalDialog

	content:      "Default content"
	title:        "Default title"
	ok:           "Ok"
	close:        "Close"
	showFooter:   true
	showOnCreate: true

	constructor: (message) ->

		@showOnCreate = false
		super()

		@title    = "Information"
		@position = 'center'
		@ok       = 'Close'
		@close    = ''
		@content  = message

		@show()

class ErrorMessageBox extends ModalDialog

	content:      "Default content"
	title:        "Default title"
	ok:           "Ok"
	close:        "Close"
	showFooter:   true
	showOnCreate: true

	constructor: (message) ->

		@showOnCreate = false
		super()

		console.log "MESSAGE=", message

		@title    = "Error"
		@position = 'center'
		@ok       = 'Close'
		@close    = ''
		@content  = message

		@show()



##|
##|  Popup menu manager class
##|
##|  This class creates a popup window that is managed like a list.  It's used
##|  mainly for context menus.   Only one popup menu can be shown at a time.
##|
##|  @example
##|      popup = new PopupMenu(title, x, y)
##|      popup.addItem "Item Text", callbackFunction, callbackData
##|

window.popupMenuVisible = false
window.popupMenuHolder  = null

class PopupMenu

	popupWidth:  300
	popupHeight: 0

	##|
	##|  Change the width of the popup menu
	##|  @param [int] popupWidth The new width
	resize: (@popupWidth) =>

		@popupHeight = window.popupMenuHolder.height()

		width  = $(window).width()
		height = $(window).height()

		if @x < 0
			@x = 0

		if @y < 0
			@y = 0

		if @popupWidth > width - 40
			@popupWidth = width - 40

		if @x + @popupWidth + 10> width
			@x = width - @popupWidth - 10

		if @y + @popupHeight + 10 > height
			@y = height - @popupHeight - 10

		window.popupMenuHolder.css
			left:  @x
			top:   @y
			width: @popupWidth

		window.popupMenuHolder.show()

		true



	##|
	##|  Create a new popup menu
	##|  @param [string] title The window title
	##|  @param [int] x the adjusted X location to open
	##|  @param [int] y the adjusted Y location to open
	##|
	constructor: (@title, @x, @y) ->

		##|
		##| if the 2nd parameter is an event, use that event to open the popup
		if @x? and @x and @x.currentTarget? and @x.currentTarget
			values = GlobalValueManager.GetCoordsFromEvent @x
			@x.stopPropagation()
			@x.preventDefault()
			@x = values.x - 150
			@y = values.y - 10

		if @x < 0 then @x = 0
		if @y < 0 then @y = 0

		if typeof window.popupMenuHolder == "undefined" or !window.popupMenuHolder

			window.popupMenuVisible = false
			id   = GlobalValueManager.NextGlobalID()
			html = $ "<ul />",
				class: "PopupMenu"
				id:    "popup#{id}"

			window.popupMenuHolder = $(html)
			window.popupMenuTimer  = 0
			$("body").append window.popupMenuHolder

			$(window.popupMenuHolder).on "mouseout", (e) =>
				if window.popupMenuVisible
					if window.popupMenuTimer then clearTimeout window.popupMenuTimer
					window.popupMenuTimer = setTimeout @closeTimer, 750
					false
				true

			$(window.popupMenuHolder).on "mouseover", (e) =>
				if window.popupMenuVisible
					if window.popupMenuTimer then clearTimeout window.popupMenuTimer
					window.popupMenuTimer = 0
				true

		window.popupMenuVisible = true
		window.popupMenuHolder.removeClass("multicol")
		html = "<li class='title'>" + @title + "</li>"
		window.popupMenuHolder.html(html)

		setTimeout () ->
			window.popupMenuHolder.show()
		, 10

		##|
		##|  Setup with default sizeing
		@resize 300
		@colCount  = 1
		@menuItems = {}
		@menuData  = {}

	##|
	##|  Close the window after the mouse drifts away from it
	closeTimer: () =>
		console.log "Popup Hide"
		window.popupMenuHolder.hide()
		window.popupMenuVisible = false
		window.popupMenuTimer = 0
		false;

	##|
	##|  Enable multiple columns in the context menu
	##|  @param colCount [int] the number of columns
	setMultiColumn: (@colCount) =>
		@resize 600
		window.popupMenuHolder.addClass("multicol")

	##|
	##|  Add a new menu item
	##|  @param name [string] the name to display
	##|  @param callbackFunction [function] A function called with the callback data when the item is selected
	##|  @param callbackData [mixed] optional callback data to include in the callback function
	##|
	addItem: (name, callbackFunction, callbackData, className) =>

		id = GlobalValueManager.NextGlobalID()
		@menuItems[id] = callbackFunction
		@menuData[id]  = callbackData

		if typeof className == "undefined"
			className = "item"

		link = $ "<li />",
			'data-id' : id
			'class'	  : className
			'html'	  : name

		if @colCount > 0
			link.addClass "multicol"

		link.on "click", (e) =>
			e.preventDefault()
			e.stopPropagation()

			##|
			##|  Close popup
			window.popupMenuHolder.hide()
			window.popupMenuVisible = false

			##|  Lookup the element selected, make a callback
			dataId = $(e.target).attr("data-id")
			if dataId
				@menuItems[dataId](e, @menuData[dataId])

			true

		window.popupMenuHolder.append link
		@resize @popupWidth

$ ->

	##|
	##|  Setup an event to monitor all clicks, if someone clicks
	##|  while the popup menu is open, close it.
	$(document).on "click", (e) =>
		if window.popupMenuVisible
			window.popupMenuHolder.hide()
			window.popupMenuVisible = false
		true

	##|
	##|  Close the popup with the escape key
	$(document).on "keypress", (e) =>
		if e.keyCode == 13
			if window.popupMenuVisible
				window.popupMenuHolder.hide()
				window.popupMenuVisible = false
		true

##|
##|  Popup calendar
##|
##|  This class creates a popup window that is managed like a list.  It's used
##|  mainly for context menus.   Only one popup menu can be shown at a time.
##|
##|  @example
##|      popup = new PopupMenuCalendar value, x, y
##|

window.popupCalendarVisible = false
window.popupCalendarHolder  = null

class PopupMenuCalendar

	popupWidth:  350
	popupHeight: 350 + 24 + 24

	onChange: (newDate) =>
		console.log "Unhandled onChange in PopupMenuCalendar for date=", newDate


	##|
	##|  Change the width of the popup menu
	##|  @param [int] popupWidth The new width
	resize: (@popupWidth) =>

		width  = $(window).width()
		height = $(window).height()

		if @x < 0
			@x = 0

		if @y < 0
			@y = 0

		if @popupWidth > width - 40
			@popupWidth = width - 40

		if @x + @popupWidth + 10> width
			@x = width - @popupWidth - 10

		if @y + @popupHeight + 10 > height
			@y = height - @popupHeight - 10

		window.popupCalendarHolder.css
			left:   @x
			top:    @y
			width:  @popupWidth
			height: @popupHeight

		window.popupCalendarHolder.show()

		true

	##|
	##|  Create a new popup menu
	##|  @param [string] value The current value if set
	##|  @param [int] x the adjusted X location to open
	##|  @param [int] y the adjusted Y location to open
	##|
	constructor: (@value, @x, @y) ->

		##|
		##| if the 2nd parameter is an event, use that event to open the popup
		if @x? and @x and @x.currentTarget? and @x.currentTarget
			values = GlobalValueManager.GetCoordsFromEvent @x
			@x.stopPropagation()
			@x.preventDefault()
			@x = values.x - 150
			@y = values.y - 10

		@title = "Select Date"
		@theMoment = GlobalValueManager.GetMoment(@value)
		if typeof @theMoment == "undefined" or @theMoment == null
			@showingMoment = moment()
		else
			@showingMoment = moment(@theMoment)

		if @x < 0 then @x = 0
		if @y < 0 then @y = 0

		$(".PopupMenuCal").remove()

		window.popupCalendarVisible = false
		id   = GlobalValueManager.NextGlobalID()
		html = $ "<div />",
			class: "PopupMenuCal"
			id:    "popup#{id}"

		window.popupCalendarHolder = $(html)
		window.popupMenuTimer  = 0
		$("body").append window.popupCalendarHolder

		$(window.popupCalendarHolder).on "mouseout", (e) =>
			if window.popupCalendarVisible
				if window.popupMenuTimer then clearTimeout window.popupMenuTimer
				window.popupMenuTimer = setTimeout @closeTimer, 1750
				false
			true

		$(window.popupCalendarHolder).on "mouseover", (e) =>
			if window.popupCalendarVisible
				if window.popupMenuTimer then clearTimeout window.popupMenuTimer
				window.popupMenuTimer = 0
			true

		@setupMonth()

		window.popupCalendarVisible = true
		@recalcDays()
		@resize @popupWidth

		##|
		##|  Setup with default sizeing
		@menuItems = {}
		@menuData  = {}

	##|
	##|  Close the window after the mouse drifts away from it
	closeTimer: () =>
		console.log "Popup Hide"
		if typeof window.popupCalendarHolder != "undefined" and window.popupCalendarHolder != null
			window.popupCalendarHolder.remove()
			window.popupCalendarHolder = null

		window.popupCalendarVisible = false
		window.popupMenuTimer = 0
		false;

	##|
	##|  Calculate and update the html based on the dates
	recalcDays: () =>

		today = moment()
		todayOfYear = today.dayOfYear()

		now = moment(@showingMoment)
		currentMonth = now.month()
		currentYear  = now.year()
		currentDay   = now.date()

		selectedDayOfYear = -1
		if typeof @theMoment != "undefined" and @theMoment != null
			selectedDayOfYear = @theMoment.dayOfYear()
			selectedYear = @theMoment.year()

		$("#calTitle").html now.format("MMM, YYYY")

		now = now.subtract(currentDay-1, "days")
		now = now.subtract(now.day(), "days")
		for n in [0..41]

			dayLetter = now.day()
			dayNum    = now.date()
			yearNum   = now.year()
			monthNum  = now.month()

			@elDay[n].html dayNum
			@elDay[n].removeClass "diffMonth"
			@elDay[n].removeClass "today"
			@elDay[n].removeClass "selected"

			if monthNum != currentMonth
				@elDay[n].addClass "diffMonth"

			if now.dayOfYear() == todayOfYear and yearNum == today.year()
				@elDay[n].addClass "today"

			if now.dayOfYear() == selectedDayOfYear and yearNum = selectedYear
				@elDay[n].addClass "selected"

			@elDay[n].attr("date-value", now.format("YYYY-MM-DD"))
			now.add(1, "day")

	setupMonth: () =>

		calTemplate = '''
			<table class='PopupCalendar'>
				<tr><td class='prev' id='calPrevious'> <i class='fa fa-angle-left'></i> </td>
					<td colspan='5' id='calTitle'> Something </td>
					<td class='next' id='calNext'><i class='fa fa-angle-right'></i> </td>
				</tr>

				<tr>
				<th class='sun'> Sun </th>
				<th class='mon'> Mon </th>
				<th class='tue'> Tue </th>
				<th class='wed'> Wed </th>
				<th class='thu'> Thu </th>
				<th class='fri'> Fri </th>
				<th class='sat'> Sat </th>
				</tr>

				<tr>
				<td class='sun' id='cal0'> x </td>
				<td class='mon' id='cal1'> x </td>
				<td class='tue' id='cal2'> x </td>
				<td class='wed' id='cal3'> x </td>
				<td class='thu' id='cal4'> x </td>
				<td class='fri' id='cal5'> x </td>
				<td class='sat' id='cal6'> x </td>
				</tr>

				<tr>
				<td class='sun' id='cal7'> x </td>
				<td class='mon' id='cal8'> x </td>
				<td class='tue' id='cal9'> x </td>
				<td class='wed' id='cal10'> x </td>
				<td class='thu' id='cal11'> x </td>
				<td class='fru' id='cal12'> x </td>
				<td class='sat' id='cal13'> x </td>
				</tr>

				<tr>
				<td class='sun' id='cal14'> x </td>
				<td class='mon' id='cal15'> x </td>
				<td class='tue' id='cal16'> x </td>
				<td class='wed' id='cal17'> x </td>
				<td class='thu' id='cal18'> x </td>
				<td class='fru' id='cal19'> x </td>
				<td class='sat' id='cal20'> x </td>
				</tr>

				<tr>
				<td class='sun' id='cal21'> x </td>
				<td class='mon' id='cal22'> x </td>
				<td class='tue' id='cal23'> x </td>
				<td class='wed' id='cal24'> x </td>
				<td class='thu' id='cal25'> x </td>
				<td class='fru' id='cal26'> x </td>
				<td class='sat' id='cal27'> x </td>
				</tr>

				<tr>
				<td class='sun' id='cal28'> x </td>
				<td class='mon' id='cal29'> x </td>
				<td class='tue' id='cal30'> x </td>
				<td class='wed' id='cal31'> x </td>
				<td class='thu' id='cal32'> x </td>
				<td class='fru' id='cal33'> x </td>
				<td class='sat' id='cal34'> x </td>
				</tr>

				<tr>
				<td class='sun' id='cal35'> x </td>
				<td class='mon' id='cal36'> x </td>
				<td class='tue' id='cal37'> x </td>
				<td class='wed' id='cal38'> x </td>
				<td class='thu' id='cal39'> x </td>
				<td class='fru' id='cal40'> x </td>
				<td class='sat' id='cal41'> x </td>
				</tr>

				<tr><td class='message' id='calMessage' colspan=7'></td></tr>

			</table>
		'''

		calCompiled = Handlebars.compile(calTemplate)
		html = calCompiled(this)

		window.popupCalendarHolder.append html

		$("#calNext").bind "click", (e) =>
			e.preventDefault()
			e.stopPropagation()
			@showingMoment.add(1, "month")
			@recalcDays()
			false

		$("#calPrevious").bind "click", (e) =>
			e.preventDefault()
			e.stopPropagation()
			@showingMoment.subtract(1, "month")
			@recalcDays()
			false

		@elDay = {}
		for n in [0..41]
			@elDay[n] = $("#cal#{n}")

			@elDay[n].bind "click toughbegin", (e) =>
				val = $(e.target).attr("date-value")
				@onChange(val)
				@closeTimer()

			@elDay[n].bind "mouseover", (e) =>
				val = $(e.target).attr("date-value")

				m = moment(val)
				age = moment().diff(m)
				age = Math.trunc(age / 86400000)
				if age == -1
					message = "1 day ago"
				else if age == 1
					message = "in 1 day"
				else if age < -1
					message = "in " + Math.abs(age) + " days"
				else
					message = Math.abs(age) + " days ago"


				@calMessage.html val + " (" + message + ")"

			@elDay[n].bind "mouseout", (e) =>
				@calMessage.html ""

		@calMessage = $("#calMessage")




$ ->

	##|
	##|  Setup an event to monitor all clicks, if someone clicks
	##|  while the popup menu is open, close it.
	$(document).on "click", (e) =>
		if window.popupCalendarVisible
			window.popupCalendarHolder.remove()
			window.popupCalendarVisible = false
		true

	##|
	##|  Close the popup with the escape key
	$(document).on "keypress", (e) ->
		if e.keyCode == 27
			if window.popupCalendarVisible
				window.popupCalendarHolder.remove()
				window.popupCalendarVisible = false
		true
##|
##|  Popup window widget
##|
##|  This class creates a popup window That has a title and is dragable.
##|
##|  @example
##|      popup = new PoupWindow(title, x, y)
##|


class PopupWindow

	popupWidth:  600
	popupHeight: 400
	isVisible:   false

	##|
	##|  Returns the available height for the body element
	getBodyHeight: () =>
		h = @popupHeight
		h -= 1 ## top padding
		h -= 1 ## bottom padding
		h -= @windowTitle.height()
		return h

	##|
	##|  Update the display, must be called if the height of the body content changes
	##|
	update: () =>
		@myScroll.refresh();

	open: () =>
		setTimeout () =>
			@update()
		, 20
		@popupWindowHolder.show()
		@isVisible = true
		true

	close: (e) =>
		if typeof e != "undefined" and e != null
			e.preventDefault()
			e.stopPropagation()

		@popupWindowHolder.hide()
		@isVisible = false
		false

	destroy: () =>

		@close()
		@popupWindowHolder.remove()
		true

	center: () =>
		width  = $(window).width()
		height = $(window).height()
		@x = (width - @popupWidth) / 2
		@y = (height - @popupHeight) / 2
		@popupWindowHolder.css
			left:   @x
			top:    @y

	##|
	##|  Resize the window to a new size
	##|
	##|  @param popupWidth [int] the new width
	##|  @param popupHeight [int] the new height
	##|
	resize: (@popupWidth, @popupHeight) =>

		width  = $(window).width()
		height = $(window).height()

		if @x == 0 and @y == 0
			@center()

		if @x < 0
			@x = 0

		if @y < 0
			@y = 0

		if @x + @popupWidth + 10> width
			@x = width - @popupWidth - 10

		if @y + @popupHeight + 10 > height
			@y = height - @popupHeight - 10

		@popupWindowHolder.css
			left:   @x
			top:    @y
			width:  @popupWidth
			height: @popupHeight

		@windowWrapper.css
			left: 0
			top: 4
			width: @popupWidth
			height: @popupHeight - 26 - 5

		setTimeout () =>
			@myScroll.refresh()
		, 100

		@popupWindowHolder.show()
		@isVisible = true

		true

	##|
	##|  Check to see if there is a saved location and move to it
	checkSavedLocation: () =>

		location = user.get "PopupLocation_#{@title}", 0
		if location != 0
			@x = location.x
			@y = location.y

	##|
	##|  Create a new window
	##|  @param title [stirng] the window title
	##|  @param x [int] upper left corner
	##|  @param y [int] top left corner
	##|
	constructor: (@title, @x, @y) ->

		if typeof @x == "undefined" or @x < 0 then @x = 0
		if typeof @y == "undefined" or @y < 0 then @y = 0

		id   = GlobalValueManager.NextGlobalID()
		html = $ "<div />",
			class: "PopupWindow"
			id:    "popup#{id}"

		@popupWindowHolder = $(html)
		$("body").append @popupWindowHolder

		##|
		##| Title div
		@windowTitle = $ "<div />",
			class: "title"
			id: "popuptitle#{id}"
			dragable: "true"
		.html @title
		@popupWindowHolder.append @windowTitle

		@windowClose = $ "<div />",
			class: "closebutton"
			id: "windowclose"
		.html "X"
		@windowTitle.append @windowClose
		@windowClose.on "click", () =>
			@close()

		##|
		##| Body div with IScroll wrapper
		@windowScroll  = $ "<div />",
			class: "scrollcontent"

		@windowWrapper = $ "<div />",
			id: "windowwrapper#{id}"
			class: "scrollable"
		.append @windowScroll

		@windowBodyWrapperTop  = $ "<div />",
			class: "windowbody"
		.css
			position: "absolute"
			top:      @windowTitle.height() + 2
			left:     0
			right:    0
			bottom:   0
		.append @windowWrapper

		@popupWindowHolder.append @windowBodyWrapperTop

		##|
		##|  Setup a scroll area within the body
		@myScroll = new IScroll "#windowwrapper#{id}",
			mouseWheel: true
			scrollbars: true
			bounce: false
			resizeScrollbars: false

		@dragabilly = new Draggabilly "#popup#{id}",
			handle: "#popuptitle#{id}"

		@dragabilly.on "dragStart", (e) =>
			@popupWindowHolder.css "opacity", "0.5"
			return false

		@dragabilly.on "dragMove", (e) =>
			x = @dragabilly.position.x
			y = @dragabilly.position.y
			w = $(window).width()
			h = $(window).height()
			if x + 50 > w then @dragabilly.position.x = w - 50
			if y + 50 > h then @dragabilly.position.y = h - 50
			if x < -50 then @dragabilly.position.x = -50
			if y < 0 then @dragabilly.position.y = 0

			user.set "PopupLocation_#{@title}",
				x: x
				y: y

			return false

		@dragabilly.on "dragStart", (e) =>
			@popupWindowHolder.css "opacity", "0.5"
			return false

		@dragabilly.on "dragEnd", (e) =>
			@popupWindowHolder.css "opacity", "0.95"
			return false


		##|
		##|  Setup with default sizeing
		@resize 600, 400
		@colCount  = 1
		@menuItems = {}
		@menuData  = {}

##
##  A Table manager class that is designed to quickly build scrollable tables
##
##  @class TableView
##  @uses iScroll5

class TableView

	imgChecked     : "<img src='images/checkbox.png' width='16' height='16' alt='Selected' />"
	imgNotChecked  : "<img src='images/checkbox_no.png' width='16' height='16' alt='Selected' />"

	##|
	##| Checkboxes
	onSetCheckbox: (checkbox_key, value) =>
		##|
		##|  By default this is a property
		# api.SetCheckbox window.currentProperty.id, checkbox_key, value
		console.log "onSetCheckbox(", checkbox_key, ",", value, ")"

	size : () =>
		return @rowData.length

	numberChecked: () =>
		total = 0
		for i, o of @rowData
			if o.checked then total++
		total

	##| Initialize the class by sending in the ID of the tag you want to become
	##| a managed table.   This should be a simple <table id='something'> tag.
	##|
	##| @param elTableHolder [jQuery Element] the $() referenced element that will hold the table
	##|
	constructor: (@elTableHolder, @showCheckboxes) ->

		@colList        = []
		@rowData        = []
		@sort           = 0
		@showHeaders    = true
		@showFilters	= true

		##|
		##|  Search filters
		@currentFilters  = {}
		@rowDataElements = {}

		##|
		##|  No context menu setup by default
		@contextMenuCallbackFunction = 0
		@contextMenuCallSetup        = 0

		if !@showCheckboxes?
			@showCheckboxes = false

		if (!@elTableHolder[0])
			console.log "Error: Table id #{@elTableHolder} doesn't exist"

		@tableConfig = {}
		@tableConfigDatabase = null

	addJoinTable: (tableName, columnReduceFunction, sourceField) =>

		columns = DataMap.getColumnsFromTable tableName, columnReduceFunction
		for col in columns
			if col.source != sourceField
				c = new TableViewCol tableName, col
				c.joinKey = sourceField
				c.joinTable = @primaryTableName
				@colList.push(c)

		true

	addTable: (tableName, columnReduceFunction, reduceFunction) =>

		@primaryTableName = tableName

		##|
		##|  Find the columns for the specific table name
		columns = DataMap.getColumnsFromTable(tableName, columnReduceFunction)
		for col in columns
			c = new TableViewCol tableName, col
			@colList.push(c)


		##|
		##|  Get the data from that table
		data = DataMap.getValuesFromTable tableName, reduceFunction
		for row in data
			if @showCheckboxes
				row.checkbox_key = tableName + "_" + row.key
				row.checked = false

			@rowData.push row

		true

	##|
	##|  Default callback for a row that is clicked
	defaultRowClick: (row, e) =>
		console.log "DEF ROW CLICK=", row, e
		false

	##|
	##|  Remove the checkbox for all items except those included
	##|  in the bookmark array that comes from the server
	resetChecked : (bookmarkArray) =>

		for i, o of @rowData
			o.checked = false
			for x, y of bookmarkArray
				if y.key == o.checkbox_key
					o.checked = true

			key = o.key
			if o.checked
				$("#check_#{@gid}_#{key}").html @imgChecked
			else
				$("#check_#{@gid}_#{key}").html @imgNotChecked

		false

	renderCheckable : (obj) =>

		if typeof obj.rowOptionAllowCheck != "undefined" and obj.rowOptionAllowCheck == false
			return "<td class='checkable'>&nbsp;</td>";

		img = @imgNotChecked
		if obj.checked
			img = @imgChecked

		if @tableName == "property" and key == window.currentProperty.id
			html = "<td class='checkable'> &nbsp; </td>"
		else
			html = "<td class='checkable' id='check_#{@gid}_#{obj.key}'>" + img + "</td>"

		return html

	setupEvents: (@rowCallback, @rowMouseover) =>

	internalSetupMouseEvents: () =>

		@elTheTable.find("tr td").bind "click touchbegin", (e) =>

			e.preventDefault()
			e.stopPropagation()

			data = @findRowFromElement e.target

			result = false
			if not e.target.constructor.toString().match(/Image/)

				defaultResult = @defaultRowClick data, e
				if defaultResult == false

					##|
					##|  Don't call a row click callback for the image which
					##|  is the checkbox column
					if typeof @rowCallback == "function"
						result = @rowCallback data, e

				else

					return false

			if result == false

				##|
				##| Check to see if it's a checkbox row
				console.log "data=", data
				if data.checked?
					data.checked = !data.checked
					key = data.key
					if data.checked
						$("#check_#{@gid}_#{key}").html @imgChecked
					else
						$("#check_#{@gid}_#{key}").html @imgNotChecked

					# console.log "CHECKED BOX gid=", @gid, " key=", key, " table_key=", data.checkbox_key, " checked=", data.checked
					@onSetCheckbox data.checkbox_key, data.checked

			false

		@elTheTable.find("tr td").bind "mouseover", (e) =>
			e.preventDefault()
			e.stopPropagation()
			if typeof @rowMouseover == "function"
				data = @findRowFromElement e.target
				@rowMouseover data, "over"
			false

		@elTheTable.find("tr td").bind "mouseout", (e) =>
			e.preventDefault()
			e.stopPropagation()
			if typeof @rowMouseover == "function"
				data = @findRowFromElement e.target
				@rowMouseover data, "out"
			false

	setupContextMenu: (@contextMenuCallbackFunction) =>

		if @contextMenuCallSetup == 1 then return true
		@contextMenuCallSetup = 1

		@elTableHolder.on "contextmenu", (e) =>

			e.preventDefault()
			e.stopPropagation()

			coords    = GlobalValueManager.GetCoordsFromEvent(e)
			data      = @findRowFromElement e.target

			if data == null
				$target = $ e.target

				##|
				##|  Check to see if it's a header column
				if $target.is "th"
					@onContextMenuHeader coords, $target.text()
					console.log "Click on header:", coords, $target.text()
					return true

			if typeof @contextMenuCallbackFunction == "function"
				@contextMenuCallbackFunction coords, data

			true

		true

	##|
	##|  Internal function called to setup the context menu on the header
	setupContextMenuHeader: =>
		@setupContextMenu @contextMenuCallbackFunction

	##|
	##|  Table cache name is set, this allows saving/loading table configuration
	setTableCacheName: (@tableCacheName) =>


	##|
	##|  Internal function called when there is a right click context menu event
	##|  on a header column.   This will display the column options.
	##|
	onContextMenuHeader: (coords, column) =>

		console.log "COORDS=", coords
		popupMenu = new PopupMenu "Column: #{column}", coords.x-150, coords.y

		if typeof @tableCacheName != "undefined" && @tableCacheName != null
			popupMenu.addItem "Configure Columns", (coords, data) =>
				@onConfigureColumns
					x: coords.x
					y: coords.y


	##|
	##|  Display a popup to adjust the columns of the table
	onConfigureColumns: (coords) =>

		popup = new PopupWindowTableConfiguration "Configure Columns", coords.x-150, coords.y
		popup.show(this)


	##|
	##|  If return's true, then the row is skipped
	filterFunction : (row) =>
		return false

	render: () =>

		@rowDataElements = {}

		##|
		##|  Create a unique ID for the table, that doesn't change
		##|  even if the table is re-drawn
		if !@gid?
			@gid = GlobalValueManager.NextGlobalID()

		##|
		##|  draw the table header
		html = "<table class='tableview' id='table#{@gid}'>"

		##|
		##|  Add headers
		if @showHeaders
			html += "<thead><tr>";

			##|
			##|  Add a checkbox to the table that is persistant
			if @showCheckboxes
				html += "<th class='checkable'>&nbsp;</th>"

			for i in @colList
				html += i.RenderHeader(i.extraClassName);

			html += "</tr>";

		if @showFilters
			html += "<thead><tr>";

			##|
			##|  Add a checkbox to the table that is persistant
			if @showCheckboxes
				html += "<th class='checkable'>&nbsp;</th>"

			for i in @colList
				html += "
					<td class='dataFilterWrapper'>
					<input class='dataFilter #{i.col.formatter.name}' data-path='/#{i.tableName}/#{i.col.source}'>
					</td>
				"

			html += "</tr>";

		##|
		##|  Start adding the body
		html += "</thead>"
		html += "<tbody id='tbody#{@gid}'>";

        # ---- html += DataMap.renderField "div", "zipcode", "city", "03105"

		# counter = 0
		if (typeof @sort == "function")
			@rowData.sort @sort

		for counter, i of @rowData

			# if @filterFunction i then continue

			if typeof i == "string"
				html += "<tr class='messageRow'><td class='messageRow' colspan='#{@colList.length+1}'"
				html += ">#{i}</td></tr>";
			else
				##|
				##|  Create the "TR" tag
				html += "<tr class='trow' data-id='#{counter}' "
				html += ">"

				##|
				##|  Add a checkbox column possibly and then render the
				##|  column using the column object.
				if @showCheckboxes
					html += @renderCheckable(i)

				for col in @colList
					if col.visible
						if col.joinKey?
							val = DataMap.getDataField col.joinTable, i.key, col.joinKey
							str = DataMap.renderField "td", col.tableName, col.col.source, val, col.col.extraClassName
						else
							str = DataMap.renderField "td", col.tableName, col.col.source, i.key, col.col.extraClassName

						html += str

				html += "</tr>";

		html += "</tbody></table>";

		@elTheTable = @elTableHolder.html(html);

		setTimeout () =>
			# globalResizeScrollable();
			if setupSimpleTooltips?
				setupSimpleTooltips();
		, 1

		##|
		##|  This is a new render which means we need to re-establish any context menu
		@contextMenuCallSetup = 0
		# @setupContextMenuHeader()
		@internalSetupMouseEvents()

		if @showFilters
			@elTheTable.find("input.dataFilter").on "keyup", @filterKeypress

		true

	##|
	##|  Key press in a filter field
	filterKeypress: (e) =>

		parts      = $(e.target).attr("data-path").split /\//
		tableName  = parts[1]
		columnName = parts[2]

		if !@currentFilters[tableName]?
			@currentFilters[tableName] = {}

		@currentFilters[tableName][columnName] = $(e.target).val()
		console.log "VAL=", @currentFilters[tableName]
		@applyFilters()

		return true

	##|
	##| Apply the filters stored in "currentFilters" to each
	##| column and show/hide the rows
	applyFilters: () =>

		filters = {}
		for counter, i of @rowData

			keepRow = true

			if @currentFilters[i.table]
				for col in @colList
					if !@currentFilters[i.table][col.col.source]? then continue

					if !filters[i.table+col.col.source]
						filters[i.table+col.col.source] = new RegExp( @currentFilters[i.table][col.col.source] , "i");

					aa = DataMap.getDataField(i.table, i.key, col.col.source)
					if !filters[i.table+col.col.source].test aa
						keepRow = false

			if !@rowDataElements[counter]
				@rowDataElements[counter] = @elTheTable.find("tr[data-id='#{counter}']")

			if keepRow
				@rowDataElements[counter].show()
			else
				@rowDataElements[counter].hide()

		true

	##
	## Add a row that takes the full width
	addMessageRow : (message) =>
		@rowData.push message
		return 0;

	clear : =>
		@elTableHolder.html ""

	reset: () =>
		@elTableHolder.html ""
		@rowData = []
		@colList = []
		true

	setFilterFunction: (filterFunction) =>

		@filterFunction = filterFunction

		##|
		##|  Force the table to redraw with a global "redrawTables" command
		GlobalValueManager.Watch "redrawTables", () =>
			@render()

	findRowFromElement: (e, stackCount) =>

		# console.log "FindRowFromElement:", e, stackCount

		if typeof stackCount == "undefined" then stackCount = 0
		if stackCount > 4 then return null

		data_id = $(e).attr("data-id")
		if data_id then return @rowData[data_id]
		parent = $(e).parent()
		if parent then return @findRowFromElement(parent, stackCount + 1)
		return null



##|
##|  Global functions required to use tables.  The cell id is a counter
##|  used to create elements with a new unique ID
##|

class TableViewCol

	##|
	##| Create a new column object.
	##|
	##| @param name [string] The name of the column
	##| @param title [string] The title to show in the header
	constructor : (@tableName, @col) ->
		@visible = @col.visible
		@width   = @col.width

		if !@visible? then @visible = true
		if !@width? then @width = ""

	RenderHeader: (extraClassName) =>
		if @visible == false then return ""

		html = "<th style='";
		if (@width) then html += "width: " + @width + ";"

		html += "'"

		if @col.extraClassName? and @col.extraClassName.length > 0
			html += "class='#{@col.extraClassName}'"

		if @col.tooltip? and @col.tooltip.length > 0
			html += " tooltip='simple' data-title='#{@col.tooltip}'"

		html += ">";
		html += @col.name;
		html += "</th>";

		return html

	onClickLink: ()=>

		window.open(@link, "showWindow", "height=800,width=1200,menubar=no,toolbar=no,location=no,status=no,resizable=yes")








##|
##| Helper class for the TableView widget.   This is a popup window
##| that takes a table and allows the columns to be selected.
##|

class PopupWindowTableConfiguration extends PopupWindow

	show: (refTable) =>

		@resize 900, 700
		@tableConfig = new TableView(@windowScroll, refTable.tableCacheName, "name")
		@tableConfig.tableConfigDatabase = refTable.tableCacheName

		console.log "tableConfigDatabase=", @tableConfig.tableConfigDatabase

		columns = []
		columns.push
			name   : "Title"
			source : "name"
			type   : "text"
			width  : "110px"

		columns.push
			name   : "Additional Information"
			source : "tooltip"
			type   : "text"

		DataMap.setDataTypes "colConfig", columns

		for col in refTable.colList
			console.log "COL=", col
			# col.checked = col.visible != false
			# @tableConfig.addRow col

		@tableConfig.addTable "colConfig"
		@tableConfig.render()

		@tableConfig.onSetCheckbox = (checkbox_key, value) =>
			console.log "HERE", checkbox_key, value
			user.tableConfigSetColumnVisible refTable.tableCacheName, checkbox_key, value

		@open()





class TableViewDetailed extends TableView

	leftWidth : 140

	realRender : () =>

		##|
		##|  Create a unique ID for the table, that doesn't change
		##|  even if the table is re-drawn
		if typeof @gid == "undefined"
			@gid = GlobalValueManager.NextGlobalID()

		@processTableConfig()

		##|
		##|  draw the table header
		html = "<table class='detailview' id='table#{@gid}'>"

		##|
		##|  Start adding the body
		html += "<tbody id='tbody#{@gid}'>";

		counter = 0
		if (typeof @sort == "function")
			@rowData.sort @sort

		for col in @colList

			col.styleFormat = ""
			col.width       = ""
			if !col.visible then continue

			##|
			##|  Create the "TR" tag
			html += "<tr class='trow' data-id='#{counter}' "
			html += ">"

			if @keyColumn and @tableName
				html += @renderCheckable(i)

			if col.visible != false
				html += "<th style='text-align: right; width: #{@leftWidth}px; '> "
				html += col.title
				html += "</th>"

			for i in @rowData

				if @basePath != 0
					col.setBasePath @basePath + "/" + i.id

				col.formatter.styleFormat = "";
				html += col.Render(counter, i)

			html += "</tr>";

		html += "</tbody></table>";

		@elTheTable = @elTableHolder.html(html);

		setTimeout () =>
			globalResizeScrollable();
			setupSimpleTooltips();
		, 100

		@contextMenuCallSetup = 0
		@setupContextMenuHeader()
		@internalSetupMouseEvents()

		true
##|
##|  Implement tooltips on elements
##|
##|  Call the function "setupSimpleTooltips" to activate.   It can be called many
##|  times.  It will find elements with the attribe tooltip='simple' and will
##|  use data-title as the text for the tooltip.
##|

window.globalHoverTimer   = 0
window.globalHoverElement = 0
window.elSimpleTooltip    = 0
window.elSimpleIndicator  = 0

initializeSimpleTooltips = () ->

	##|
	##|  The first time simple tooltips are needed,
	##|  add the holder elements to the body and create fast reference pointers to them.
	##|

	$("body").append $ "<i>",
		class:	"fa fa-lightbulb-o"
		id:     "simpleTooltipIndicator"

	$("body").append $ "<div>",
		class:	"simpleTooltip"
		id:     "simpleTooltip"

	window.elSimpleTooltip = $("#simpleTooltip")
	window.elSimpleIndicator = $("#simpleTooltipIndicator")

##|
##|  A timer that is activated on mouseover from a tooltip enabled element
##|
simpleTooltipTimer = ()->
	title = window.globalHoverElement.attr("data-title")
	pos   = window.globalHoverElement.position()

	window.elSimpleTooltip.html(title).show()

	x = pos.left + (window.globalHoverElement.width() / 2) - (window.elSimpleTooltip.width() / 2)
	y = pos.top  - 10 - window.globalHoverElement.height() - 40

	if (x < 0) then x = 0
	if (x + window.globalHoverElement.width() > $(window).width())
		x = $(window).width - 10 - window.globalHoverElement.width()

	window.elSimpleTooltip.show().css
		left: x
		top : y

setupSimpleTooltips = () ->

	if window.elSimpleTooltip == 0
		initializeSimpleTooltips()

	$("body").find('[tooltip="simple"]').each (idx, el) ->

		$el = $(el)
		tooltipID = $el.attr("data-id-tooltip");
		if ! tooltipID
			tooltipID = GlobalValueManager.NextGlobalID()
			$el.attr("data-id-tooltip", tooltipID)

			$el.on 'mouseover', (e) ->
				window.elSimpleIndicator.show()
				if window.globalHoverTimer then clearTimeout window.globalHoverTimer
				window.globalHoverElement = $(e.target)
				window.globalHoverTimer   = setTimeout simpleTooltipTimer, 1000
				true

			$el.on 'mouseout', (e) ->
				window.elSimpleIndicator.hide()
				if window.globalHoverTimer then clearTimeout window.globalHoverTimer
				window.elSimpleTooltip.hide()
				true


class AddressNormalizer

    lat: null
    lon: null

    tile_x: null
    tile_y: null

    house_number     : null
    street_number    : null
    street_prefix    : null
    street_direction : null
    street_suffix    : null

    unit_number: null

    city    : null
    state   : null
    zipcode : null
    zipfour : null

    seperator: ', '

    constructor: (options) ->
        ##|  options can be used to pass in known information
        if options.city? then @city = @fixTitleCase options.city
        if options.lat? then @lat = options.lat
        if options.lon? then @lon = options.lon
        if options.tile_x? then @tile_x = options.tile_x
        if options.tile_y? then @tile_y = options.tile_y
        if options.street_number? then @street_number = options.street_number
        if options.street_prefix? then @street_prefix = options.street_prefix
        if options.street_direction? then @street_direction = options.street_direction
        if options.street_suffix? then @street_suffix = options.street_suffix
        if options.unit_number? then @unit_number = options.unit_number
        if options.state? then @state = options.state
        if options.zipcode? then @zipcode = options.zipcode
        if options.zipfour? then @zipfour = options.zipfour

    ##|
    ##|  Return the single line of text that is the address
    ##|  normalized to be comparable
    getDisplayAddress: () =>
        "#{@getAddressPart()}, #{if @unit_number then @unit_number+', ' else ''} #{if @city then @city+', ' else '' } #{if @state then @state+', ' else ''} #{if @zipcode then @extractZip() else ''}"
    ##|
    ##|  Convert text from unknown case to title case, as in
    ##|  PHOENIX becomes Phoenix
    ##|  NEW york becomes New York
    ##|  MCARTHUR AIRpORT becomes McArthur Airport
    fixTitleCase: (strTitleText) =>
        strTitleText.replace /\w\S*/g, (txt) ->
            txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()

    ##| process the address part and create address part string
    ##| ex. street_prefix, street_direction, street_suffix Unit
    getAddressPart: () =>
        suffixParser = new StreetSuffixParser();
        "#{if @street_number then @street_number else ""} #{if @street_prefix then @street_prefix else ""} #{if @street_direction then @street_direction else ""} #{if @street_suffix then suffixParser.getSuffix(@street_suffix) else ''}"

    ##| extract 5 digit zipcode if zipcode is 9 digits
    extractZip: () =>
        if(/^\d{5}-\d{4}$/.test @zipcode)
            zip = @zipcode.split('-')[0]
        else
            zip = @zipcode



try
    GlobalAddressNormalizer  = new AddressNormalizer({city:'sample'});
catch e
    console.log "Exception while registering global Address Formatter:", e
##|
##| Global values manager, providers a number of static functions that are designed
##| to help in general purpose ways.   This is required by all components in the folder
##|


##|
##|  Global variables

class GlobalValueManager

    @globalCellID    : 0
    @globalData      : {}


    ##| Returns a sequential number unique across the app.   Used to
    ##| generate id numbers for new html elements.
    ##|
    ##| @example
    ##|    id = GlobalValueManager.NextGlobalID()
    ##|
    @NextGlobalID = () ->
        gid = GlobalValueManager.globalCellID++
        return gid

    ##|
    ##| Set a global value given some unique key
    ##|
    ##| @param [mixed] gid The reference key
    ##| @param [mixed] obj The value to store
    ##|
    ##| @example
    ##|    GlobalValueManager.SetGlobal "key", "value"
    ##|
    @SetGlobal = (gid, obj) ->
        GlobalValueManager.globalData[gid] = obj
        return gid

    ##|
    ##| Get a global value given some unique key.  Returns undefined
    ##| if nothing has been saved with that key.
    ##|
    ##| @param [mixed] gid The reference key
    ##|
    ##| @example
    ##|    GlobalValueManager.GetGlobal "key"
    ##|
    @GetGlobal = (gid) ->
        return GlobalValueManager.globalData[gid];


    ##|
    ##|  Returns the HTML required to display a loading spinner.
    ##|
    @GetLoading = () ->
        return "<i class='fa fa-3x fa-asterisk fa-spin'></i>"

    ##|
    ##|  Given an event object such as that received on a mouse over, find the
    ##|  actual coordinates which may be adjusted depending on scroll position
    ##|  and browser type.
    ##|
    ##|  @param [Event] e the event object
    ##|  @return [Object] returns an object with x/y defined
    ##|
    @GetCoordsFromEvent = (e) ->

        clickX = 0
        clickY = 0

        if (e.clientX || e.clientY) && document.body && document.body.scrollLeft != null
            clickX = e.clientX + document.body.scrollLeft
            clickY = e.clientY + document.body.scrollTop

        if (e.clientX || e.clientY) && document.compatMode == 'CSS1Compat' && document.documentElement && document.documentElement.scrollLeft != null
            clickX = e.clientX + document.documentElement.scrollLeft
            clickY = e.clientY + document.documentElement.scrollTop

        if e.pageX || e.pageY
            clickX = e.pageX
            clickY = e.pageY

        values = {}
        values.x = clickX
        values.y = clickY
        return values


    ##|
    ##| Get a number from one of the values
    ##| where we look at each value and if defined use
    ##| that, but if not, use the next one
    ##|
    ##| @param [Number] a The first value to check
    ##| @param [Number] b The second value to check
    ##| @param [Number] c The third value to check
    ##| @param [Number] d The forth value to check
    ##|
    ##| @example
    ##|    price = GlobalValueManager.GetNumber possiblePrice1, possiblePrice2
    ##|
    @GetNumber = (a, b, c, d) ->

        if typeof a != "undefined" and a != null
            value = parseInt(a)
            if value then return value

        if typeof b != "undefined" and  b != null
            value = parseInt(b)
            if value then return value

        if typeof c != "undefined" and c != null
            value = parseInt(c)
            if value then return value

        if typeof d != "undefined" and d != null
            value = parseInt(d)
            if value then return value

        return 0

    ##|
    ##| Given a date in a human readable form, parse it and return the Moment
    ##| object (see momentjs) that represents the date/time.
    ##|
    ##| @param [string] date The date string to parse
    ##|
    ##| @note returns null if the date is invalid
    ##|
    @GetMoment = (date) ->

        if date == null
            return null;

        if typeof date != "string"
            return null;

        date = date.replace "T", " "

        if date.match /\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d/
            return moment(date, "YYYY-MM-DD HH:mm:ss")

        if date.match /\d\d\d\d.\d\d.\d\d/
            return moment(date, "YYYY-MM-DD")

        if date.match /\d\d-\d\d-\d\d\d\d/
            return moment(date, "MM-DD-YYYY")

        return null;

    ##|
    ##| Days ago formatting
    @DaysAgo = (stamp) ->

        m = GlobalValueManager.GetMoment(stamp)
        if m == null then return 0

        age = moment().diff(stamp)
        age = Math.trunc(age / 86400000)

        if age == 1 then return "1 day"
        return age + " days"


    ##|
    ##| Given a date in a Moment object, return an HTML display
    ##| This includes a span with the age of the date such as 32 days
    ##|
    ##| @param [Moment] date The date object
    ##|
    @DateFormat = (stamp) ->

        if stamp == null
            if val then return val
            return "&mdash;"

        html = "<span class='fdate'>" + stamp.format("MM/DD/YYYY") + "</span>"

        age = moment().diff(stamp)
        age = age / 86400000

        if (age < 401)
            age = numeral(age).format("#") + " d"
        else if (age < 365 * 2)
            age = numeral(age / 30.5).format("#") + " mn"
        else
            age = numeral(age / 365).format("#.#") + " yrs"

        html += "<span class='fage'>" + age + "</span>"


    ##|
    ##|  Give some text, returns a title version, for example
    ##|  give "user_name" it returns User Name
    ##|
    @Ucwords = (str) ->
        return (str + '').replace /^([a-z\u00E0-\u00FC])|\s+([a-z\u00E0-\u00FC])/g, ($1) ->
            return $1.toUpperCase();

    ##|
    ##|  Trigger an event and pass data to that event.   When combined with the
    ##|  "Watch" function this is a simple form of "pub sub" within the global
    ##|  app scope.
    @Trigger = (eventName, dataObject) ->
        $("body").trigger eventName, dataObject
        true

    ##|
    ##|  See Trigger for information on Watch/Trigger for global pub sub events.
    @Watch = (eventName, delegate) ->
        $("body").on eventName, delegate
        true



class StreetSuffixParser

  ##| suffixes taken from http://pe.usps.gov/text/pub28/28apc_002.htm
  suffixes:
    ALY : ['ALLEE','ALLEY','ALLY','ALY']
    ANX : ['ANEX','ANNEX','ANNX','ANX']
    ARC : ['ARC','ARCADE']
    AVE : ['AVE','AVEN','AV','AVENU','AVENUE','AVN','AVNUE']
    BYU : ['BAYOO','BAYOU']
    BCH: ['BCH','BEACH']
    BND: ['BEND','BND']
    BLF: ['BLF','BLUFF','BLUF']
    BLFS: ['BLUFFS']
    BTM: ['BOT','BTM','BOTTOM','BOTTM']
    BLVD:['BLVD','BOUL','BOULEVARD','BOULV']
    BR: ['BR','BRNCH','BRANCH']
    BRG: ['BRDGE','BRIDGE','BRG']
    BRK: ['BROOK','BRK']
    BRKS: ['BROOKS']
    BG: ['BURG']
    BGS: ['BURGS']
    BYP: ['BYP','BYPA','BYPAS','BYPASS','BYPS']
    CP: ['CAMP','CP','CMP']
    CYN: ['CANYN','CANYON','CNYN']
    CPE: ['CAPE','CPE']
    CSWY: ['CAUSEWAY','CAUSWA','CSWY']
    CTR: ['CEN','CENT','CENTER','CENTR','CENTRE','CNTER','CNTR','CTR']
    CTRS: ['CENTERS']
    CIR: ['CIR','CIRC','CIRCL','CIRCLE','CRCL','CRCLE']
    CIRS: ['CIRCLES']
    CLF: ['CLF','CLIFF']
    CLFS: ['CLFS','CLIFFS']
    CLB: ['CLUB','CLB']
    CMN: ['COMMON']
    CMNS: ['COMMONS']
    COR: ['COR','CORNOR']
    CORS: ['CORS','CORNORS']
    CRSE: ['CRSE','COURSE']
    CT: ['CT','COURT']
    CTS: ['CTS','COURTS']
    CV: ['COVE','CV']
    CVS: ['COVES']
    CRK: ['CREEK','CRK']
    CRES: ['CRESCENT','CRES','CRSENT','CRSNT']
    CRST: ['CREST']
    XING: ['CROSSING','CRSSNG','XING']
    XRD: ['CROSSROAD']
    XRDS: ['CROSSROADS']
    CURV: ['CURVE']
    DL: ['DALE','DL']
    DM: ['DAM','DM']
    DV: ['DIVIDE','DIV','DV','DVD']
    DR: ['DRIV','DR','DRIVE','DRV']
    DRS: ['DRIVES']
    EST: ['ESTATE','EST']
    ESTS: ['ESTATES','ESTS']
    EXPY: ['EXPRESS','EXP','EXPR','EXPRESSWAY','EXPW','EXPY']
    EXT: ['EXTENSION','EXT','EXTN','EXTNSN']
    EXTS: ['EXTS']
    FALL: ['FALL']
    FLS: ['FALLS','FLS']
    FRY: ['FERRY','FRRY','FRY']
    FLD: ['FIELD','FLD']
    FLDS: ['FIELDS','FLDS']
    FLT: ['FLT','FLAT']
    FLTS: ['FLATS','FLTS']
    FRD: ['FORD','FRD']
    FRDS: ['FORDS']
    FRST: ['FOREST','FORESTS','FRST']
    FRG: ['FORG','FORGE','FRG']
    FRGS: ['FORGES']
    FRK: ['FORK','FRK']
    FRKS: ['FORKS','FRKS']
    FT: ['FORT','FT','FRT']
    FWY: ['FREEWAY','FREEWY','FRWAY','FRWY','FWY']
    GDN: ['GARDEN','GARDN','GRDEN','GRDN'],
    GDNS: ['GARDENS','GDNS','GRDNS']
    GTWY: ['GATEWAY','GATEWY','GATWAY','GTWAY','GTWY']
    GLN: ['GLEN','GLN']
    GLNS: ['GLENS']
    GRN: ['GRN','GREEN']
    GRNS: ['GREENS']
    GRV: ['GROV','GROVE','GRV']
    GRVS: ['GROVES']
    HBR: ['HARB','HARBOR','HARBR','HRBOR','HBR']
    HBRS: ['HARBORS']
    HVN: ['HAVEN','HVN']
    HTS: ['HT','HTS']
    HWY: ['HIGHWAY','HIGHWY','HIWAY','HIWY','HWAY','HWY']
    HL: ['HL','HILL']
    HLS: ['HLS','HILLS']
    HOLW: ['HLLW','HOLLOW','HOLLOWS','HOLW','HOLWS']
    INLT: ['INLT']
    IS: ['ISLAND','IS','ISLND']
    ISS: ['ISLANDS','ISS','ISLNDS']
    ISLE: ['ISLE','ISLES']
    JCT: ['JCTION','JCT','JCTN','JUNCTION','JUNCTN','JUNCTON']
    JCTS: ['JCTNS','JCTS','JUNCTIONS']
    KY: ['KEY','KY']
    KYS: ['KEYS','KYS']
    KNL: ['KNL','KNOL','KNOLL']
    KNLS: ['KNLS','KNOLLS']
    LK: ['LAKE','LK']
    LKS: ['LAKES','LKS']
    LAND: ['LAND']
    LNDG: ['LANDING','LNDNG','LNDG']
    LN: ['LN','LANE']
    LGT: ['LGN','LIGHT']
    LGTS: ['LIGTHS']
    LF: ['LF','LOAF']
    LCK: ['LCK','LOCK']
    LCKS: ['LCKS','LOCKS']
    LDG: ['LDG','LDGE','LODG','LODGE']
    LOOP: ['LOOP','LOOPS']
    MALL: ['MALL']
    MNR: ['MANOR','MNR']
    MNRS: ['MANORS','MNRS']
    MDW: ['MEADOW']
    MDWS: ['MDWS','MDW','MEADOWS','MEDOWS']
    MEWS: ['MEWS']
    ML: ['MILL']
    MLS: ['MILLS']
    MSN: ['MISSN','MSSN']
    MTWY: ['MOTORWAY']
    MT: ['MNT','MT','MOUNT']
    MTN: ['MNTAIN','MNTN','MOUNTAIN','MOUNTIN','MTIN','MTN']
    MTNS: ['MOUNTAINS','MNTNS']
    NCK: ['NECK','NCK']
    ORCH: ['ORCH','ORCHARD','ORCHRD']
    OVAL: ['OVAL','OVL']
    OPAS: ['OVERPASS']
    PARK: ['PARK','PRK']
    PARK: ['PARKS']
    PKWY: ['PARKWAY','PARKWY','PKWAY','PKWY','PKY']
    PKWYS: ['PARKWAYS','PKWYS']
    PASS: ['PASS']
    PSGE: ['PASSAGE']
    PATH: ['PATH','PATHS']
    PIKE: ['PIKE','PIKES']
    PNE: ['PINE']
    PNES: ['PINES','PNES']
    PL: ['PL']
    PLN: ['PLAIN','PLN']
    PLNS: ['PLAINS','PLNS']
    PLZ: ['PLAZA','PLZ','PLZA']
    PT: ['PT','POINT']
    PTS: ['PTS','POINTS']
    PRT: ['PRT','PORT']
    PRTS: ['PRTS','PORTS']
    PR: ['PRAIRIE','PR','PRR']
    RADL: ['RADL','RADIAL','RAD','RADIEL']
    RAMP: ['RAMP']
    RNCH: ['RANCH','RANCHES','RNCH','RNCHS']
    RPD: ['RAPID','RPD']
    RPDS: ['RAPIDS','RPDS']
    RST: ['REST','RST']
    RDG: ['RDG','RDGE','RIDGE']
    RDGS: ['RIDGES','RDGS']
    RIV: ['RIV','RIVER','RVR','RIVR']
    RD: ['ROAD','RD']
    RDS: ['ROADS','RDS']
    RTE: ['ROUTE']
    ROW: ['ROW']
    RUE: ['RUE']
    RUN: ['RUN']
    SHL: ['SHOAL','SHL']
    SHLS: ['SHOALS','SHLS']
    SHR: ['SHOAR','SHORE','SHR']
    SHRS: ['SHOARS','SHORES','SHRS']
    SKWY: ['SKYWAY']
    SPG: ['SPNG','SPG','SPRING','SPRNG']
    SPGS: ['SPNGS','SPGS','SPRINGS','SPRNGS']
    SPUR: ['SPUR']
    SPURS: ['SPURS']
    SQ: ['SQ','SQR','SQRE','SQU','SQUARE']
    SQS: ['SQRS','SQUARES']
    STA: ['STATION','STA','STATN','STN']
    STRA: ['STRA','STRAV','STRAVEN','STRAVENUE','STRAVN','STRVN','STRVNUE']
    STRM: ['STREAM','STRM','STREME']
    ST: ['STREET','STRT','ST','STR']
    STS: ['STREETS']
    SMT: ['SMT','SUMIT','SUMITT','SUMMIT']
    TER: ['TER','TERR','TERRACE']
    TRWY: ['THROUGHWAY']
    TRCE: ['TRACE','TRACES','TRCE']
    TRAK: ['TRACK','TRACKS','TRAK','TRKS','TRK']
    TRFY: ['TRAFFICWAY']
    TRL: ['TRAIL','TRAILS','TRL','TRLS']
    TRLR: ['TRAILER','TRLR','TRLRS']
    TUNL: ['TUNEL','TUNL','TUNLS','TUNNEL','TUNNELS','TUNNL']
    TPKE: ['TRNPK','TURNPIKE','TURNPK']
    UPAS: ['UNDERPASS']
    UN: ['UN','UNION']
    UNS: ['UNIONS']
    VLY: ['VALLEY','VALLY','VLLY','VLY']
    VLYS: ['VALLEYS','VLYS']
    VIA: ['VDCT','VIA','VIADCT','VIADUCT']
    VW: ['VIEW','VW']
    VWS: ['VIEWS','VWS']
    VLG: ['VILL','VILLAG','VILLAGE','VILLG','VILLIAGE','VLG']
    VLGS: ['VILLAGES','VLGS']
    VL: ['VILLE','VL']
    VIS: ['VIS','VIST','VISTA','VST','VSTA']
    WALK: ['WALK']
    WALK: ['WALKS']
    WALL: ['WALL']
    WAY: ['WY','WAY']
    WAYS: ['WAYS']
    WL: ['WELL']
    WLS: ['WELLS','WLS']


  ##| function to get the suffix from name
  getSuffix:(name) =>
    suffix = null
    keys = Object.keys @suffixes
    keys.forEach (key)=>
      @suffixes[key].forEach (f) ->
        if f.toLowerCase() is name.toLowerCase()
          suffix = key
    suffix

try
    GlobalStreetSuffixParser = new StreetSuffixParser();
catch e
    console.log "Exception while registering global Address Formatter:", e