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
	styleFormat: "text-align: right;"

	format: (data, options, path) =>
		if options? and options != null
			return numeral(DataFormatter.getNumber data).format(options)
		return numeral(DataFormatter.getNumber data).format("#,###")

	unformat: (data, path) =>
		return DataFormatter.getNumber data

class DataFormatNumber extends DataFormatterType

	name: "number"
	styleFormat: "text-align: right;"

	format: (data, options, path) =>
		return numeral(DataFormatter.getNumber data).format("#,###.[##]")

	unformat: (data, path) =>
		return DataFormatter.getNumber data

class DataFormatFloat extends DataFormatterType

	name: "decimal"
	styleFormat: "text-align: right;"

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
	styleFormat: "text-align: right;"

	format: (data, options, path) =>
		if !data? or data == null or data == 0 or data == ""
			return "&mdash;"

		return numeral(DataFormatter.getNumber data).format('$ #,###.[##]')

	unformat: (data, path) =>
		return DataFormatter.getNumber data

class DataFormatPercent extends DataFormatterType

	name: "percent"
	styleFormat: "text-align: right;"

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
	styleFormat: "text-align: right;"

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

	openEditor: (elParent, left, top, width, height, currentValue, path) =>

		##|
		##|  Show a popup menu
		p = new PopupMenu "Options", left, top
		p.addItem "Yes", (coords, data) =>
			@saveValue data
		, 1
		p.addItem "No", (coords, data) =>
			console.log data
			@saveValue data
		, 0
		true

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

class DataFormatSimpleObject extends DataFormatterType
	name: "simpleobject"

	format: (data,options,path) =>
		if !options.compile
			throw new Error "compilation template not defined inside options.compile"
		return Handlebars.compile(options.compile)(data)
	unformat: (data,path) =>
		return data
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
	globalDataFormatter.register(new DataFormatSimpleObject())

catch e
	console.log "Exception while registering global Data Formatter:", e
