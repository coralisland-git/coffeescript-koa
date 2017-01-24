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

	# @property [String] align
	align: null

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

		# console.log "parentElement=", parentElement
		# console.log "currentValue=",  currentValue

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

			if e.keyCode == 9
				##|
				##|  Tab key handles save
				@saveValue(@elEditor.val())
				@editorShowing = false
				@elEditor.hide()

				##|
				##|  Send out a tab key
				# if globalKeyboardEvents?
				# 	globalKeyboardEvents.emitEvent "tab", [ e ]

				return false

			if e.keyCode == 13
				@saveValue(@elEditor.val())
				@editorShowing = false
				@elEditor.hide()
				return false

			if e.keyCode == 27
				@editorShowing = false
				@elEditor.hide()
				return false

			if @allowKey e.keyCode
				return true
			else
				return false

		$("document").on "click", (e) =>
			console.log "Click"

	##|
	##|  Trigger when the mouse goes down on any place in the window, this
	##|  will remove the input field if you click outside the cell.
	onGlobalMouseDown: (e)=>
		if e.target.className == "dynamic_edit"
			#globalKeyboardEvents.once "global_mouse_down", @onGlobalMouseDown
			return true

		@editorShowing = false
		@elEditor.hide()
		true



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

		globalKeyboardEvents.once "global_mouse_down", @onGlobalMouseDown

	## onFocus: (elParent, left, top, width, height, currentValue, path) =>
	## define as null if there is no on click action by default.
	## click can only happen if the caller determines that editing is not possible
	##
	onFocus: null


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

		if typeof data == "object"
			if Array.isArray(data)
				data = data.filter((a)->a?).join(", ")
			else
				list = []
				for varName, value of data
					if !value? then continue
					list.push "#{varName}=#{value}"
				data = list.join(", ")

		if data.length > 300
			return data[0..300] + "..."

		return data

	renderTooltip: (row, value, tooltipWindow)=>
		if !value? then return false

		if typeof value == "string"
			h = 60
			w = 320
			if value.length > 100 then w = 440
			if value.length > 200 then w = 640
			if value.length > 300 then h = 440

			tooltipWindow.setSize(w, h)
			tooltipWindow.getBodyWidget().addClass "text"
			tooltipWindow.html value
			return true

		console.log "renderTooltip row=", row, "value=", value
		return false

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

		if data.length == 0
			return ""

		return "<span class='memo'>" + data[0..200] + "</span><span class='fieldicon'><i class='si si-eyeglasses'></i></span>"

	## -------------------------------------------------------------------------------------------------------------
	## funtion to unformat the currently formatted data
	##
	## @param [Object] data data to be unformatted
	## @param [String] path path where the value is being edited
	## @return [Object] data unformatted data
	##
	unformat: (data, path) =>

		return data

	onFocus: (e, col, data) =>
		console.log "e=", e
		console.log "col=", col
		console.log "data=", data

		text = data[col]
		if text? and typeof text == "string" and text.length > 0
			content = "<br><textarea style='width:100%; height: 600px; font-size: 16px; line-height: 20px; font-family: Consolas, monospaced, arial;'>#{text}</textarea>"
			m = new ModalDialog
				showOnCreate : true
				content      : content
				title        : "View Contents"
				ok           : "Done"
				close        : ""

		true

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

		w = $(window).width()
		h = $(window).height()

		if w > 1000
			w = 1000
		else if w > 800
			w = 800
		else
			w = 600

		if h > 1000
			h = 1000
		else if h > 800
			h = 800
		else if h > 600
			h = 600
		else
			h = 400

		##|
		##|  Show a popup menu
		popup = new PopupWindow("Text Editor");
		popup.resize w, h
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

		w = $(window).width()
		h = $(window).height()

		width = 800
		height = 600
		if width > w then width = w - 10
		if height > h then height = h - 10

		top  = (h-height)/2
		left = (w-width)/2

		popup = new PopupWindow("Source Code");
		popup.resize w, h

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

		codeMode = "javascript"
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

	# @property [String] align
	align: "right"

	width: 90

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

	# @property [String] align
	align: "right"

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

		num = DataFormatter.getNumber data

		if data == null or (typeof data == "string" and data.length == 0)
			return ""

		if isNaN(num)
			return "[#{num}]"

		if !options? or options == ""
			options = "#,###.[##]"

		try
			return numeral(num).format(options)
		catch e
			console.log "Exception formatting number [#{num}] using [#{optinos}]"
			retunr "[#{num}]"


	## -------------------------------------------------------------------------------------------------------------
	## funtion to unformat the currently formatted data
	##
	## @param [Object] data data to be unformatted
	## @param [String] path path where the value is being edited
	## @return [Object] data unformatted data
	##
	unformat: (data, path) =>
		console.log "unformat number:", data
		return DataFormatter.getNumber data


## -------------------------------------------------------------------------------------------------------------
## class for decimal data type
##
## @extends [DataFormatterType] data formatted data
##
class DataFormatFloat extends DataFormatterType

	# @property [String] name name of the data type
	name: "decimal"

	# @property [String] align
	align: "right"

	width: 100

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
		if !data? then return ""
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

	# @property [String] align
	align: "right"

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
			return ""

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

	# @property [String] align
	align: "right"

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
	## funtion to open editor as flatpickr
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
		if !@elEditor
			@elEditor = $ "<input />",
				type: "text"
				class: "dynamic_edit"

			@appendEditor()
			@elEditor.on 'keydown', (e) =>
				##| if editor is closed then close datepicker
				if !@editorShowing
					@datePicker.close()

		@datePicker = new flatpickr @elEditor[0],
			allowInput: true
			parseDate: (dateString) ->
				DataFormatter.getMoment dateString
			onChange: (dateObject, dateString) =>
				@saveValue dateObject
				@editorShowing = false
				@elEditor.hide()
			onOpen: (dateObj, dateStr, instance) =>
				instance.setDate(new Date(currentValue))

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

		if Array.isArray(currentValue)
			return currentValue.sort().join(", ")

		values = []
		for idx, obj of currentValue
			values.push obj
		return values.sort().join(", ")

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


class DataFormatMultiselect extends DataFormatterType

	# @property [String] name name of the data type
	name: "multiselect"

	# @property [Array|Object] options provided options for selection
	options: []

	## -------------------------------------------------------------------------------------------------------------
	## funtion to open multiselect editor
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
			content      : "Select the list of items"
			title        : "Select options"
			ok           : "Save"

		if typeof currentValue == "string"
			currentValue = currentValue.split ','

		m.getForm().addMultiselect "select1", "Selection", currentValue.join(','),
			options: @options

		m.getForm().onSubmit = (form) =>
			@saveValue form.select1
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
		@options = options
		if typeof currentValue == "string"
			currentValue = currentValue.split ','

		if Array.isArray(currentValue)
			return currentValue.join(", ")

		values = []
		for idx, obj of currentValue
			values.push obj
		return values.join(", ")

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
		if !@elEditor
			@elEditor = $ "<input />",
				type: "text"
				class: "dynamic_edit"

			@appendEditor()
			@elEditor.on 'keydown', (e) =>
				##| if editor is closed then close datepicker
				if !@editorShowing
					@datePicker.close()

		@datePicker = new flatpickr @elEditor[0],
			allowInput: true
			parseDate: (dateString) ->
				DataFormatter.getMoment dateString
			onChange: (dateObject, dateString) =>
				@saveValue dateObject
				@editorShowing = false
				@elEditor.hide()
			onOpen: (dateObj, dateStr, instance) =>
				instance.setDate (new Date(currentValue))
				instance.setTime DataFormatter.getMoment(new Date(currentValue)).format('HH:mm:ss')
			enableTime: true
			time_24hr: true

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

	# @property [String] align
	align: "right"

	## -------------------------------------------------------------------------------------------------------------
	## funtion to open editor with flatpickr
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
		if !@elEditor
			@elEditor = $ "<input />",
				type: "text"
				class: "dynamic_edit"

			@appendEditor()
			@elEditor.on 'keydown', (e) =>
				##| if editor is closed then close datepicker
				if !@editorShowing
					@datePicker.close()

		@datePicker = new flatpickr @elEditor[0],
			allowInput: true
			parseDate: (dateString) ->
				DataFormatter.getMoment dateString
			onChange: (dateObject, dateString) =>
				@saveValue dateObject
				@editorShowing = false
				@elEditor.hide()
			onOpen: (dateObj, dateStr, instance) =>
				instance.setDate (new Date(currentValue))
				instance.setTime DataFormatter.getMoment(new Date(currentValue)).format('HH:mm:ss')
			enableTime: true
			time_24hr: true

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
			return ""

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
	width: 100

	## -------------------------------------------------------------------------------------------------------------
	## Takes meters in, returns a formatted string
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
	format: (data, options, path) =>
		if data == 0 then return 0

		##|
		##|  DATA is in METERS
		##|

		feet = 3.28084 * data
		# feet = 5280 * data
		if feet < 50 then return "< 50 ft"
		if feet < 1000 then return Math.ceil(feet) + " ft"
		data = feet / 5280
		return numeral(data).format('#,###.##') + " mi"

	## -------------------------------------------------------------------------------------------------------------
	## funtion to unformat the currently formatted data
	##
	## @param [Object] data data to be unformatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data unformatted data
	##
	unformat: (data, path) =>
		console.log "Unformat distance doesn't work:", data
		val = DataFormatter.getNumber(data)
		return val


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

	textYes: "<i class='fa fa-circle'></i> Yes"
	textNo : "<i class='fa fa-circle-thin'></i> No"
	textNotSet: "<i class='fa fa-fs'></i> Not Set"

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

		if currentValue
			currentValue = false
		else
			currentValue = true

		@saveValue currentValue
		return true


	## -------------------------------------------------------------------------------------------------------------
	## funtion to format the currently passed data
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
	format: (data, options, path) =>
		if !data? then return @textNotSet
		if data == "" then return @textNotSet
		if data == null or data == 0 or data == false then return @textNo
		return @textYes

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

		if typeof data == "boolean"
			if data then return true
			return false

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
	## funtion to open editor with flatpickr
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
		if !@elEditor
			@elEditor = $ "<input />",
				type: "text"
				class: "dynamic_edit"

			@appendEditor()
			@elEditor.on 'keydown', (e) =>
				##| if editor is closed then close datepicker
				if !@editorShowing
					@datePicker.close()

		@datePicker = new flatpickr @elEditor[0],
			allowInput: true
			parseDate: (dateString) ->
				DataFormatter.getMoment dateString
			onChange: (dateObject, dateString) =>
				@saveValue dateObject
				@editorShowing = false
				@elEditor.hide()
			onOpen: (dateObj, dateStr, instance) =>
				instance.setDate (new Date(currentValue))
				instance.setTime DataFormatter.getMoment(new Date(currentValue)).format('HH:mm:ss')
			enableTime: true
			time_24hr: true

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

	## -------------------------------------------------------------------------------------------------------------
	## funtion to format the currently passed data
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
	format: (data, options, path) =>

		if !data? then return ""

		if typeof data == "string"
			stamp = new Date(data)
		else if typeof data == "number"
			stamp = new Date(data)
		else if typeof data == "object" and data.getTime?
			stamp = data
		else
			return ""

		age = new Date().getTime() - stamp.getTime()
		age /= 1000

		# console.log "timeAgo data=", data, " age=", age

		if age < 60
			txt = numeral(age).format("#") + " sec"
		else if age < (60 * 60)
			txt = numeral(age/60).format("#") + " min"
		else if age > 86400
			days = Math.floor(age / 86400)
			hrs  = Math.floor((age - (days * 86400)) / (60 * 60))
			if days != 1 then daysTxt = "days" else daysTxt = "day"
			if hrs > 0 and days < 30
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
	width: 90

	align: "right"

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
		if !data?
			return "Not set"

		if data? and Array.isArray(data)
			if data.length == 0
				return "Not set"

			if typeof data[0] == "string"
				return data.sort().filter((a)->a?).join(", ")

		return "View"
		# return "View:" + JSON.stringify(data)

	renderTooltip: (row, value, tooltipWindow)=>

		if !value? then return false

		height = 20
		str = "<table>"
		for varName, val of value
			str += "<tr><td>"
			str += varName
			str += "</td><td>"
			str += val
			str += "</tr>"
			height += 20

		str += "</table>"

		tooltipWindow.html str
		tooltipWindow.setSize(400, height)
		return true

	onFocus: (e, col, data) =>
		console.log "e=", e
		console.log "col=", col
		console.log "data=", data

	## -------------------------------------------------------------------------------------------------------------
	## funtion to unformat the currently formatted data
	##
	## @param [Object] data data to be unformatted
	## @param [String] path path where the value is being edited
	## @return [Object] data unformatted data
	##
	unformat: (data,path) =>
		console.log "unformat simple:", data
		return data

## -------------------------------------------------------------------------------------------------------------
## class for simpleobject data type
##
## @extends [DataFormatterType]
##
class DataFormatLink extends DataFormatterType

	# @property [String] name name of the data type
	name: "link"

	width: 70

	clickable: true

	## -------------------------------------------------------------------------------------------------------------
	## funtion to format the currently passed data
	##
	## @param [Object] data data to be formatted
	## @param [Object] options additonal options defined for the datatype
	## @param [String] path path where the value is being edited
	## @return [Object] data formatted data
	##
	format: (data,options,path) =>
		if !data? then return ""
		if /www/.test data then return "Open Link"
		if /^http/.test data then return "Open Link"
		if /^ftp/.test data then return "Open FTP"
		if data.length > 0
			return data
		return ""


	## -------------------------------------------------------------------------------------------------------------
	## funtion to unformat the currently formatted data
	##
	## @param [Object] data data to be unformatted
	## @param [String] path path where the value is being edited
	## @return [Object] data unformatted data
	##
	unformat: (data,path) =>
		console.log "TODO: DataFormatLink.unformat not implemented:", data
		return data

	openEditor: (elParent, left, top, width, height, currentValue, path) =>
		##|
		##| TODO:  Open a dialog to edit the link and validate it
		console.log "TODO: openEditor not implemented for link"
		return null

	onFocus: (e, col, data) =>
		console.log "click, col=", col, "data=", data
		url = data[col]
		if url? and url.length > 0
			win = window.open(url, "_blank")
			win.focus()

		true


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
	globalDataFormatter.register(new DataFormatMultiselect())
	globalDataFormatter.register(new DataFormatMemo())
	globalDataFormatter.register(new DataFormatDuration())
	globalDataFormatter.register(new DataFormatLink())


catch e
	console.log "Exception while registering global Data Formatter:", e
