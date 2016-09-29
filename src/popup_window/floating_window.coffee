
class FloatingWindow

	constructor: (x, y, @w, @h, parent)->

		@el = $ "<div class='floatingWindow'/>"
		@el.css
			position : "absolute"
			left     : x
			top      : y
			width    : @w
			height   : @h
			zIndex   : 1503432
			border   : "1px solid blue"
			overflow : "hidden"
			display  : "none"

		console.log "Creating window x=#{x}, y=#{y}, w=#{@w}, h=#{@h}"

		if parent?
			$(parent).append @el
		else
			$(document.body).append @el

class FloatingSelect extends FloatingWindow

	getOptionHeight: ()=>
		return 24

	close: ()=>
		if @table?
			@el.remove()
			delete @table

	hide: ()=>
		@el.hide();
		if @table?
			console.log "Hiding, removing table?", @el
		return true

	show: ()=>
		@el.show()
		@showTable()
		@table.onResize()
		true

	onResize: ()=>
		@el.show()
		if @table? then @table.onResize()

	setTable: (@tableName, @columns, config)=>
		GlobalClassTools.addEventManager(this)

	showTable: ()=>

		if @table?
			console.log "Table already setup"
			return @table

		@table = new TableView(@el, false)
		@table.showGroupPadding = false
		@table.showResize       = false

		@table.addTable @tableName, (colName)=>
			##|
			##|  Column filter function only shows specific columns
			##|
			if !@columns? then return true
			for opt in @columns
				if opt == colName.getSource()
					return true

			return false

		@table.on "click_row", (row, e)=>
			@emitEvent "select", [ row ]
			true

		@table.on "focus_cell", (path, item)=>
			console.log "on focus cell:", path, item
			@emitEvent "preselect", [ item.id, item ]
			true

		if config? and config.showHeaders
			@table.showHeaders = true
			# @table.showFilters = true

		@table.setFixedSize(@w, @h)
		@table.render()
		@table.onResize()

class TypeaheadInput

	onKeypress: (e)=>
		val = @elInputField.val()

		if e.keyCode == 27
			@win.hide()
			return false

		if e.keyCode == 13
			@emitEvent "change", val
			@win.hide()
			return false

		if e.keyCode == 38
			@moveCellUp()
			return

		if e.keyCode == 40
			@moveCellDown()
			return

		# console.log "Keypress during input", e, e.keyCode, val
		@setFilter val
		return true

	onFocus: (e)=>
		@emitEvent "focus", [e]
		@clearIcon.show()
		@elInputField.select()
		console.log "Showing window", @win
		@win.show()
		@win.onResize()
		return true

	onBlur: (e)=>
		if ! @excludeBlurEvent
			@emitEvent "blur", [e]
			@clearIcon.hide()
			# @win.hide()
		return true

	moveCellUp: (e)=>
		if !@win.table.currentFocusCell?
			@win.table.setFocusFirstCell()
		else
			@win.table.moveCellUp()
		true

	moveCellDown: (e)=>
		if !@win.table.currentFocusCell?
			@win.table.setFocusFirstCell()
		else
			@win.table.moveCellDown()
		true

	setFilter: (newText)=>
		@emitEvent "filter", [ newText, @win.table ]
		true

	constructor: (InputField, @tableName, @columns, options) ->

		config =
			rowHeight : 24
			numRows   : 10

		@elInputField = $(InputField)

		##| add clear text input icon
		@elInputField.after $('<i />',
			'class': 'fa fa-times floatingDropdownIcon'
			style: 'margin-left: -20px; float:right; display:none')
		@clearIcon = @elInputField.next()
		##| bind clear icon click event
		@clearIcon.on 'click', (e) =>
			@elInputField.val('')
			@emitEvent 'change', ''
			@setFilter ""
			@elInputField.focus()
		.on 'mouseover', () =>
			@excludeBlurEvent = true
		.on 'mouseleave', () =>
			@excludeBlurEvent = false
		##|
		##|
		GlobalClassTools.addEventManager(this)
		@elInputField.on "keyup", @onKeypress
		@elInputField.on "focus", @onFocus
		@elInputField.on "blur",  @onBlur
		@elInputField.on "click", @onFocus

		# globalKeyboardEvents.on "up", @moveCellUp
		# globalKeyboardEvents.on "down", @moveCellDown

		scrollTop  = document.body.scrollTop
		scrollLeft = document.body.scrollLeft

		posTop     = @elInputField.offset().top
		posLeft    = @elInputField.offset().left

		scrollTop = 0
		scrollLeft = 0

		width      = @elInputField.outerWidth(true)
		height     = @elInputField.outerHeight(true)

		px = @elInputField.position()

		console.log "Scroll=#{scrollLeft},#{scrollTop} pos=#{posLeft},#{posTop} px=", px

		$.extend config, options

		# @win = new FloatingSelect(posLeft + scrollLeft, posTop+scrollTop+height, width, config.rowHeight*config.numRows, @elInputField.parent())
		@win = new FloatingSelect(posLeft, posTop + height, width, config.rowHeight*config.numRows, @elInputField.parent())
		@win.setTable @tableName, @columns

		@win.on "select", (row)=>
			col = @columns[0]
			@elInputField.val(row[col])
			@emitEvent "change", row[col]
			@win.hide()

		@win.on "preselect", (value, itemRow)=>
			@elInputField.val(value)
			@elInputField.select()


class TableDropdownMenu

	setValue: (row)=>
		col = @columns[0]
		if @config.render? and typeof @config.render == "function"
			@elInputField.html @config.render(row[col], row)
		else
			@elInputField.html row[col]

		@emitEvent "change", row[col]

	constructor: (HolderField, @tableName, @columns, options)->

		@config =
			rowHeight:   24
			numRows:     10
			showHeaders: false
			width:       null
			height:      null
			render:      null
			allowEmpty:  true
			placeholder: "Select an option"

		$.extend @config, options

		@elInputField = $ "<div class='floatingDropdownValue'/>"
		@elCarot = $ "<i class='fa fa-arrow-down floatingDropdownIcon'></i>"

		@elHolder = $(HolderField)
		@elHolder.addClass "floatingDropdown"
		@elHolder.append @elInputField
		@elHolder.append @elCarot
		@elInputField.html @config.placeholder

		GlobalClassTools.addEventManager(this)

		scrollTop  = document.body.scrollTop
		scrollLeft = document.body.scrollLeft

		posTop     = @elInputField.offset().top
		posLeft    = @elInputField.offset().left

		width      = @elInputField.outerWidth(true)
		height     = @elInputField.outerHeight(true)
		if !@config.width?  then @config.width = width
		if !@config.height? then @config.height = @config.rowHeight*@config.numRows

		if @config.allowEmpty? and @config.allowEmpty == false
			##|
			##|  Select the first row automatically
			tableRows = DataMap.getValuesFromTable @tableName
			if tableRows? then @setValue tableRows.shift()

		@elInputField.on "click", (e)=>
			@win.show()
			##|
			##|  Setup an event so we can close this popup
			globalKeyboardEvents.once "global_mouse_down", (ee)=>
				console.log "Onetime mouse down, closing after other events"
				setTimeout ()=>
					@win.hide()
				, 1050
				return false

		@win = new FloatingSelect(posLeft + scrollLeft, posTop+scrollTop+height, @config.width, @config.height)
		@win.setTable @tableName, @columns, @config

		@win.on "select", (row)=>
			@setValue row
			@win.hide()
