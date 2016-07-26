## -------------------------------------------------------------------------------------------------------------
## Base class for DataFormatterType
##
class DataFormatterType

	# @property [String] name to give the datatype name
	name          : 	""

	# @property [Integer] width
	width         : null

	# @property [Boolean] editorShowing if to show editor or not
	editorShowing : false

	# @property [String] editorPath suggests current path of the value being edited
	editorPath    : ""

	# @property [String] styleFormat to apply additional style
	styleFormat: ""

	## -------------------------------------------------------------------------------------------------------------
	## funtion to get the formatted data fromt the datatype
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additional options to be used in the format for ex. options for select
	## @param [String] path the path where the formatted data needs to be returned
	## @return null
	##
	format: (data, options, path) =>
		return null

	## -------------------------------------------------------------------------------------------------------------
	## funtion to remove formating applied and get raw data
	##
	## @param [Object] data data to be unformatted
	## @param [String] path the path where the formatted data needs to be returned
	## @return null
	##
	unformat: (data, path) =>
		return null

	## -------------------------------------------------------------------------------------------------------------
	## funtion to allow specific key stroke on datatype
	##
	## @param [Integer] keycode keycode that is allowed
	## @return [Boolean]
	##
	allowKey: (keyCode) =>
		return true

	## -------------------------------------------------------------------------------------------------------------
	## funtion to edit the data displayed using data type
	##
	## @param [JqueryElement] parentElement parent Element of the currently rendered data
	## @param [Object] currentValue currentValue of the datatype
	## @param [String] path the path where the data is being displayed
	## @param [Function] onSaveCallback the function that should be called when data is updated
	##
	editData: (parentElement, currentValue, path, @onSaveCallback) =>

		left     = 0
		top      = 0
		width    = 100
		height   = 40
		elParent = null

		@editorPath = path

		console.log "parentElement=", parentElement
		console.log "currentValue=", currentValue

		if parentElement?

			elParent = $(parentElement)
			pos      = elParent.position()
			left     = pos.left
			top      = pos.top
			width	 = elParent.outerWidth(false)
			height	 = elParent.outerHeight(false)

			# console.log "PARENT=", parentElement
			# console.log "POS=", pos
			# console.log "W=", width, height
			# console.log "offset=", elParent.offset()

			left = elParent.offset().left
			top  = elParent.offset().top

		@editorShowing = true
		@openEditor(elParent, left, top, width, height, currentValue, path)

	## -------------------------------------------------------------------------------------------------------------
	## funtion to save the new value to the datatype holder element
	##
	## @param [Object] newValue new value that needs to be updateds to be returned
	## @return [Boolean]
	##
	saveValue: (newValue) =>

		newValue = @unformat(newValue, @editorPath)
		console.log "Saving value", newValue
		if @onSaveCallback?
			@onSaveCallback @editorPath, newValue
		true

	## -------------------------------------------------------------------------------------------------------------
	## funtion to append the editor html to the document
	##
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


	## -------------------------------------------------------------------------------------------------------------
	## funtion to open the dynamic default text editor
	##
	## @param [JqueryElement] elParent parent element where text editor needs to be displayed
	## @param [Integer] left left position offset
	## @param [Integer] top top position offset
	## @param [Integer] width width of the editor
	## @param [Integer] height height of the editor
	## @param [Object] currentValue current value of the cell
	## @param [String] path path where the value is being edited
	## @return null
	##
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
		@elEditor.select()


## -------------------------------------------------------------------------------------------------------------
## class for Text datatype
##
## @extends [DataFormatterType
##
class DataFormatText extends DataFormatterType

	# @property [String] name name of the data type
	name: "text"

	## -------------------------------------------------------------------------------------------------------------
	## funtion to format the currently passed data
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
	format: (data, options, path) =>

		if !data?
			return ""

		return data

	## -------------------------------------------------------------------------------------------------------------
	## funtion to unformat the currently formatted data
	##
	## @param [Object] data data to be unformatted
	## @param [String] path path where the value is being edited
	## @return [Object] data unformatted data
	##
	unformat: (data, path) =>

		return data

## -------------------------------------------------------------------------------------------------------------
## class for Text datatype - Edit as HTML/Popup
##
## @extends [DataFormatterType
##
class DataFormatMemo extends DataFormatterType

	# @property [String] name name of the data type
	name: "memo"

	## -------------------------------------------------------------------------------------------------------------
	## funtion to format the currently passed data
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
	format: (data, options, path) =>

		if !data?
			return ""

		return data

	## -------------------------------------------------------------------------------------------------------------
	## funtion to unformat the currently formatted data
	##
	## @param [Object] data data to be unformatted
	## @param [String] path path where the value is being edited
	## @return [Object] data unformatted data
	##
	unformat: (data, path) =>

		return data

	## -------------------------------------------------------------------------------------------------------------
	## funtion to open editor including ace code editor
	##
	## @param [JqueryObject] elParent parent element
	## @param [Integer] left left position offset
	## @param [Integer] top top position offset
	## @param [Integer] width width of the editor
	## @param [Integer] height height of the editor
	## @param [Object] currentValue current value of the cell
	## @param [String] path path where the value is being edited
	## @return null
	##
	openEditor: (elParent, left, top, width, height, currentValue, path) =>

		cx = left + (width / 2)
		cy = top  - 10

		##|
		##|  Show a popup menu
		popup = new PopupWindow("Text Editor");
		popup.resize 800, 400
		popup.centerToPoint cx, cy-(popup.popupHeight/2)

		navButtonSave = new NavButton "Save", "toolbar-btn navbar-btn btn-primary"
		navButtonSave.onClick = (e)=>
			@saveValue codeEditor.getContent()
			popup.destroy()

		navButtonCancel = new NavButton "Cancel", "toolbar-btn navbar-btn btn-danger cancel-btn"
		navButtonCancel.onClick = (e)=>
			popup.destroy()

		popup.addToolbar [ navButtonSave, navButtonCancel ]

		tag = $ "<div />",
			id: "editor_" + GlobalValueManager.NextGlobalID()
			height: popup.windowWrapper.height()

		popup.on "resize", (ww, hh)=>
			tag.css "height", popup.windowWrapper.height()

		popup.windowScroll.append tag

		codeMode = "markdown"
		if typeof @options == "string" then codeMode = @options

		codeEditor = new CodeEditor tag
		# codeEditor.popupMode().setMode codeMode

		if !currentValue
			code = ''
		else if typeof currentValue isnt 'string'
			code = currentValue.toString()
		else
			code = currentValue

		codeEditor.setContent code

		popup.update()
		true




## -------------------------------------------------------------------------------------------------------------
## class for SourceCode data type
##
## @extends [DataFormatText]
##
class DataFormatSourceCode extends DataFormatText

	# @property [String] name name of the data type
	name : "sourcecode"

	## -------------------------------------------------------------------------------------------------------------
	## funtion to open editor including ace code editor
	##
	## @param [JqueryObject] elParent parent element
	## @param [Integer] left left position offset
	## @param [Integer] top top position offset
	## @param [Integer] width width of the editor
	## @param [Integer] height height of the editor
	## @param [Object] currentValue current value of the cell
	## @param [String] path path where the value is being edited
	## @return null
	##
	openEditor: (elParent, left, top, width, height, currentValue, path) =>
		##|
		##|  Show a popup menu
		popup = new PopupWindow("Source Code");
		popup.resize 600, 400

		navButtonSave = new NavButton "Save", "toolbar-btn navbar-btn btn-primary"
		navButtonSave.onClick = (e)=>
			@saveValue codeEditor.getContent()
			popup.destroy()

		navButtonCancel = new NavButton "Cancel", "toolbar-btn navbar-btn btn-danger cancel-btn"
		navButtonCancel.onClick = (e)=>
			popup.destroy()

		popup.addToolbar [ navButtonSave, navButtonCancel ]

		tag = $ "<div />",
			id: "editor_" + GlobalValueManager.NextGlobalID()
			height: popup.windowWrapper.height()

		popup.windowScroll.append tag

		codeMode = "javacript"
		if typeof @options == "string" then codeMode = @options

		codeEditor = new CodeEditor tag
		codeEditor.popupMode().setTheme "tomorrow_night_eighties"
			.setMode codeMode

		console.log "CURRENT=", currentValue

		if !currentValue
			code = ''
		else if typeof currentValue isnt 'string'
			code = currentValue.toString()
		else
			code = currentValue

		codeEditor.setContent code

		popup.update()
		true

## -------------------------------------------------------------------------------------------------------------
## class for int data type
##
## @extends [DataFormatterType]
##

class DataFormatInt extends DataFormatterType

	# @property [String] name name of the data type
	name: "int"

	# @property [String] styleFormat
	styleFormat: "text-align: right;"

	## -------------------------------------------------------------------------------------------------------------
	## funtion to format the currently passed data
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
	format: (data, options, path) =>
		if data == null or (typeof data == "string" and data.length == 0)
			return ""

		if options? and options != null
			return numeral(DataFormatter.getNumber data).format(options)
		return numeral(DataFormatter.getNumber data).format("#,###")

	## -------------------------------------------------------------------------------------------------------------
	## funtion to unformat the currently formatted data
	##
	## @param [Object] data data to be unformatted
	## @param [String] path path where the value is being edited
	## @return [Object] data unformatted data
	##
	unformat: (data, path) =>
		num = DataFormatter.getNumber data
		if isNaN(num) then return ""
		return Math.round(num)


## -------------------------------------------------------------------------------------------------------------
## class for number data type
##
## @extends [DataFormatterType]
##
class DataFormatNumber extends DataFormatterType

	# @property [String] name name of the data type
	name: "number"

	# @property [String] styleFormat
	styleFormat: "text-align: right;"

	## -------------------------------------------------------------------------------------------------------------
	## funtion to format the currently passed data
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
	format: (data, options, path) =>
		num = DataFormatter.getNumber data

		if data == null or (typeof data == "string" and data.length == 0)
			return ""

		if isNaN(num)
			return "[#{num}]"

		return numeral().format("#,###.[##]")

	## -------------------------------------------------------------------------------------------------------------
	## funtion to unformat the currently formatted data
	##
	## @param [Object] data data to be unformatted
	## @param [String] path path where the value is being edited
	## @return [Object] data unformatted data
	##
	unformat: (data, path) =>
		return DataFormatter.getNumber data


## -------------------------------------------------------------------------------------------------------------
## class for decimal data type
##
## @extends [DataFormatterType] data formatted data
##
class DataFormatFloat extends DataFormatterType

	# @property [String] name name of the data type
	name: "decimal"

	# @property [String] styleFormat
	styleFormat: "text-align: right;"

	## -------------------------------------------------------------------------------------------------------------
	## funtion to allow specific key code
	##
	## @param [Integer] keyCode keyCode to allow
	## @return [Boolean]
	##
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

	## -------------------------------------------------------------------------------------------------------------
	## funtion to format the currently passed data
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
	format: (data, options, path) =>
		if !data? then return "&mdash;"
		if options? and /#/.test options
			return numeral(DataFormatter.getNumber data).format(options)
		else
			return numeral(DataFormatter.getNumber data).format("#,###.##")

	## -------------------------------------------------------------------------------------------------------------
	## funtion to unformat the currently formatted data
	##
	## @param [Object] data data to be unformatted
	## @param [String] path path where the value is being edited
	## @return [Object] data unformatted data
	##
	unformat: (data, path) =>
		return DataFormatter.getNumber data


## -------------------------------------------------------------------------------------------------------------
## class for money data type
##
## @extends [DataFormatterType]
##
class DataFormatCurrency extends DataFormatterType

	# @property [String] name name of the data type
	name: "money"

	# @property [String] styleFormat
	styleFormat: "text-align: right;"

	## -------------------------------------------------------------------------------------------------------------
	## funtion to format the currently passed data
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
	format: (data, options, path) =>
		if !data? or data == null or data == 0 or data == ""
			return "&mdash;"

		return numeral(DataFormatter.getNumber data).format('$ #,###.[##]')

	## -------------------------------------------------------------------------------------------------------------
	## funtion to unformat the currently formatted data
	##
	## @param [Object] data data to be unformatted
	## @param [String] path path where the value is being edited
	## @return [Object] data unformatted data
	##
	unformat: (data, path) =>
		return DataFormatter.getNumber data


## -------------------------------------------------------------------------------------------------------------
## class for percent data type
##
## @extends [DataFormatterType]
##
class DataFormatPercent extends DataFormatterType

	# @property [Strin] name name of the data type
	name: "percent"

	# @property [String] styleFormat
	styleFormat: "text-align: right;"

	## -------------------------------------------------------------------------------------------------------------
	## funtion to format the currently passed data
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
	format: (data, options, path) =>
		return numeral(DataFormatter.getNumber data).format('#,###.[##] %')

	## -------------------------------------------------------------------------------------------------------------
	## funtion to unformat the currently formatted data
	##
	## @param [Object] data data to be unformatted
	## @param [String] path path where the value is being edited
	## @return [Object] data unformatted data
	##
	unformat: (data, path) =>
		num = DataFormatter.getNumber data
		return num


## -------------------------------------------------------------------------------------------------------------
## class for date data type
##
## @extends [DataFormatterType]
##
class DataFormatDate extends DataFormatterType

	# @property [String] name name of the data type
	name: "date"

	# @property [Integer] width
	width: 65

	## -------------------------------------------------------------------------------------------------------------
	## funtion to format the currently passed data
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
	format: (data, options, path) =>
		m = DataFormatter.getMoment data
		if !m? then return ""
		return m.format "MM/DD/YYYY"

	## -------------------------------------------------------------------------------------------------------------
	## funtion to unformat the currently formatted data
	##
	## @param [Object] data data to be unformatted
	## @param [String] path path where the value is being edited
	## @return [Object] data unformatted data
	##
	unformat: (data, path) =>
		m = DataFormatter.getMoment data
		if !m? then return ""
		return m.format "YYYY-MM-DD HH:mm:ss"

## -------------------------------------------------------------------------------------------------------------
## class for datetime data type
##
## @extends [DataFormatterType]
##
class DataFormatTags extends DataFormatterType

	# @property [String] name name of the data type
	name: "tags"

	## -------------------------------------------------------------------------------------------------------------
	## funtion to open editor including ace code editor
	##
	## @param [JqueryObject] elParent parent element
	## @param [Integer] left left position offset
	## @param [Integer] top top position offset
	## @param [Integer] width width of the editor
	## @param [Integer] height height of the editor
	## @param [Object] currentValue current value of the cell
	## @param [String] path path where the value is being edited
	## @return null
	##
	openEditor: (elParent, left, top, width, height, currentValue, path) =>

		m = new ModalDialog
			showOnCreate : false
			content      : "Enter the list of items"
			title        : "Edit options"
			ok           : "Save"

		if typeof currentValue == "string"
			currentValue = currentValue.split ','

		m.getForm().addTagsInput "input1", "Value", currentValue.join(',')

		m.getForm().onSubmit = (form) =>
			@saveValue form.input1.split(",")
			m.hide()

		m.show()

	## -------------------------------------------------------------------------------------------------------------
	## funtion to format the currently passed data
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
	format: (currentValue, options, path) =>

		if typeof currentValue == "string"
			currentValue = currentValue.split ','

		return currentValue.join(", ")

	## -------------------------------------------------------------------------------------------------------------
	## funtion to unformat the currently unformatted data
	##
	## @param [Object] data data to be unformatted
	## @param [String] path path where the value is being edited
	## @return [Object] data unformatted data
	##
	unformat: (currentValue, path) =>
		if typeof currentValue == "string"
			currentValue = currentValue.split ','
		return currentValue


## -------------------------------------------------------------------------------------------------------------
## class for datetime data type
##
## @extends [DataFormatterType]
##
class DataFormatDateTime extends DataFormatterType

	# @property [String] name name of the data type
	name: "datetime"

	## -------------------------------------------------------------------------------------------------------------
	## funtion to open editor including ace code editor
	##
	## @param [JqueryObject] elParent parent element
	## @param [Integer] left left position offset
	## @param [Integer] top top position offset
	## @param [Integer] width width of the editor
	## @param [Integer] height height of the editor
	## @param [Object] currentValue current value of the cell
	## @param [String] path path where the value is being edited
	## @return null
	##
	openEditor: (elParent, left, top, width, height, currentValue, path) =>

		##|
		##|  Show a popup menu
        @picker = new PopupMenuCalendar currentValue, top, left
        @picker.onChange = (newValue) =>
        	@saveValue newValue
		true

	## -------------------------------------------------------------------------------------------------------------
	## funtion to format the currently passed data
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
	format: (data, options, path) =>
		m = DataFormatter.getMoment data
		if !m? then return ""
		return m.format "ddd, MMM Do, YYYY h:mm:ss a"

	## -------------------------------------------------------------------------------------------------------------
	## funtion to unformat the currently unformatted data
	##
	## @param [Object] data data to be unformatted
	## @param [String] path path where the value is being edited
	## @return [Object] data unformatted data
	##
	unformat: (data, path) =>
		m = DataFormatter.getMoment data
		if !m? then return ""
		return m.format "YYYY-MM-DD HH:mm:ss"


## -------------------------------------------------------------------------------------------------------------
## class for age data type
##
## @extends [DataFormatterType]
##
class DataFormatDateAge extends DataFormatterType

	# @property [String] name name of the data type
	name: "age"

	# @property [Integer] width
	width: 135

	# @property [String] styleFormat
	styleFormat: "text-align: right;"

	## -------------------------------------------------------------------------------------------------------------
	## funtion to format the currently passed data
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
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

	## -------------------------------------------------------------------------------------------------------------
	## funtion to unformat the currently formatted data
	##
	## @param [Object] data data to be unformatted
	## @param [String] path path where the value is being edited
	## @return [Object] data unformatted data
	##
	unformat: (data, path) =>
		m = DataFormatter.getMoment data
		if !m? then return ""
		return m.format "YYYY-MM-DD HH:mm:ss"


## -------------------------------------------------------------------------------------------------------------
## class for enum data type
##
## @extends [DataFormatterType]
##
class DataFormatEnum extends DataFormatterType

	# @property [String] name name of the data type
	name: "enum"

	## -------------------------------------------------------------------------------------------------------------
	## funtion to open editor including ace code editor
	##
	## @param [JqueryObject] elParent parent element
	## @param [Integer] left left position offset
	## @param [Integer] top top position offset
	## @param [Integer] width width of the editor
	## @param [Integer] height height of the editor
	## @param [Object] currentValue current value of the cell
	## @param [String] path path where the value is being edited
	## @return null
	##
	openEditor: (elParent, left, top, width, height, currentValue, path) =>

		##|
		##|  Show a popup menu
		p = new PopupMenu "Options", left, top
		if typeof @options == "string"
			@options = @options.split ","

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

	## -------------------------------------------------------------------------------------------------------------
	## In this case, the options is an array or a comma seperated list of values
	## data must be one of those values of a numeric index to those values.
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
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

	## -------------------------------------------------------------------------------------------------------------
	## funtion to unformat the currently formatted data
	##
	## @param [Object] data data to be unformatted
	## @param [String] path path where the value is being edited
	## @return [Object] data unformatted data
	##
	unformat: (data, path) =>
		return data


## -------------------------------------------------------------------------------------------------------------
## class for distance data type
##
## @extends [DataFormatterType]
##
class DataFormatDistance extends DataFormatterType

	# @property [String] name name of the data type
	name: "distance"

	# @property [Integer] width
	width: 80

	## -------------------------------------------------------------------------------------------------------------
	## Takes meters in, returns a formatted string
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
	format: (data, options, path) =>
		val = DataFormatter.getNumber data
		ft = 3280.8 * val
		if (ft < 1000) then return numeral(ft).format("#,###") + " ft."
		mi = 0.621371 * val
		return numeral(mi).format("#,###.##") + " mi.";

	## -------------------------------------------------------------------------------------------------------------
	## funtion to unformat the currently formatted data
	##
	## @param [Object] data data to be unformatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data unformatted data
	##
	unformat: (data, path) =>
		val = DataFormatter.getNumber(data)
		return val * 3280.8


## -------------------------------------------------------------------------------------------------------------
## class for boolean data type
##
## @extends [DataFormatterType]
##
class DataFormatBoolean extends DataFormatterType

	# @property [String] name name of the data type
	name: "boolean"

	# @property [Integer] width
	width: 40

	## -------------------------------------------------------------------------------------------------------------
	## funtion to open editor including ace code editor
	##
	## @param [JqueryObject] elParent parent element
	## @param [Integer] left left position offset
	## @param [Integer] top top position offset
	## @param [Integer] width width of the editor
	## @param [Integer] height height of the editor
	## @param [Object] currentValue current value of the cell
	## @param [String] path path where the value is being edited
	## @return null
	##
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

	## -------------------------------------------------------------------------------------------------------------
	## funtion to format the currently passed data
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
	format: (data, options, path) =>
		if !data? then return "No"
		if data == null or data == 0 or data == false then return "No"
		return "Yes"

	## -------------------------------------------------------------------------------------------------------------
	## funtion to unformat the currently formatted data
	##
	## @param [Object] data data to be unformatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data unformatted data
	##
	unformat: (data, path) =>
		if !data? then return false
		if data == null or data == 0 then return false
		if data == "No" or data == "no" or data == "false" or data == "off" then return false
		return true


## -------------------------------------------------------------------------------------------------------------
## class for timeago data type
##
## @extends [DataFormatterType]
##
class DataFormatTimeAgo extends DataFormatterType

	# @property [String] name name of the data type
	name: "timeago"

	# @property [Integer] width
	width: 135

	## -------------------------------------------------------------------------------------------------------------
	## funtion to format the currently passed data
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
	format: (data, options, path) =>
		stamp = DataFormatter.getMoment data
		if stamp == null
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

	## -------------------------------------------------------------------------------------------------------------
	## funtion to format the currently passed data
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
	unformat: (data, path) =>
		m = DataFormatter.getMoment data
		if !m? then return ""
		return m.format "YYYY-MM-DD HH:mm:ss"


## -------------------------------------------------------------------------------------------------------------
## class for timeago data type
##
## @extends [DataFormatterType]
##
class DataFormatDuration extends DataFormatterType

	# @property [String] name name of the data type
	name: "duration"

	# @property [Integer] width
	width: 70

	## -------------------------------------------------------------------------------------------------------------
	## funtion to format the currently passed data
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
	format: (data, options, path) =>
		if typeof data == "string"
			data = parseFloat options

		sec = data / 1000
		if sec < 60
			txt = numeral(sec).format("#.###") + " sec"
		else if sec < (60 * 60 * 2)
			min = Math.floor(sec / 60)
			sec = sec - (min * 60)
			txt = min + " min, " + Math.floor(sec) + " sec."
		else
			hrs = Math.floor(sec / (60*60))
			min = Math.floor(sec - (hrs * 60 * 60))
			txt = hrs + " hrs, " + min + " min"

		return txt

	## -------------------------------------------------------------------------------------------------------------
	## funtion to format the currently passed data
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
	unformat: (data, path) =>
		return data


## -------------------------------------------------------------------------------------------------------------
## class for simpleobject data type
##
## @extends [DataFormatterType]
##
class DataFormatSimpleObject extends DataFormatterType

	# @property [String] name name of the data type
	name: "simpleobject"

	## -------------------------------------------------------------------------------------------------------------
	## funtion to format the currently passed data
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
	format: (data,options,path) =>
		if !options.compile
			throw new Error "compilation template not defined inside options.compile"
		return Handlebars.compile(options.compile)(data)

	## -------------------------------------------------------------------------------------------------------------
	## funtion to unformat the currently formatted data
	##
	## @param [Object] data data to be unformatted
	## @param [String] path path where the value is being edited
	## @return [Object] data unformatted data
	##
	unformat: (data,path) =>
		return data


## -------------------------------------------------------------------------------------------------------------
## register all the data type with the globalDataFormatter
##
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
	globalDataFormatter.register(new DataFormatSourceCode())
	globalDataFormatter.register(new DataFormatTags())
	globalDataFormatter.register(new DataFormatMemo())
	globalDataFormatter.register(new DataFormatDuration())

catch e
	console.log "Exception while registering global Data Formatter:", e
