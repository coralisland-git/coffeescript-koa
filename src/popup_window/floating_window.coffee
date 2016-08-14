
class FloatingWindow extends WidgetTag

    constructor: (x, y, w, h, parent)->

        super("div", "floatingWindow")

        @base = new WidgetBase()
        @base.el.append @el

        @el.css
            position : "absolute"
            left     : x
            top      : y
            width    : w
            height   : h
            zIndex   : 59001
            overflow : 'hidden'
            display  : "none"
            border   : "1px solid #202020"

        if parent?
            $(parent).append @el
        else
            $(document.body).append @el

class FloatingSelect extends FloatingWindow

    getOptionHeight: ()=>
        return 24

    setFilter: (text)=>

        col = @columns[0]
        @table.currentFilters[@tableName] = {}
        @table.currentFilters[@tableName][col] = text
        @table.applyFilters()
        true

    close: ()=>
        if @table?
            @el.remove()
            delete @table

    setTable: (@tableName, @columns, config)=>

        GlobalClassTools.addEventManager(this)

        if !@table?
            @table = new TableView(@el, false)

            @table.addTable @tableName, (colName)=>
                ##|
                ##|  Column filter function only shows specific columns
                ##|
                if !@columns? then return true
                for opt in @columns
                    if opt == colName.source then return true
                return false

            @table.on "click_row", (row, e)=>
                @emitEvent "select", [ row ]
                true

            @table.on "focus_cell", (path, item)=>
                console.log "on focus cell:", path, item
                @emitEvent "preselect", [ item.id, item ]
                true

            @table.setSimpleAndFixed()
            if config? and config.showHeaders
                @table.showHeaders = true
                # @table.showFilters = true

            @table.render()

        return @table

class TypeaheadInput

    onKeypress: (e)=>
        val = @elInputField.val()
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

        console.log "Keypress during input", e, e.keyCode, val
        @win.setFilter val
        return true

    onFocus: (e)=>
        @emitEvent "focus", [e]
        @elInputField.select()
        @win.show()
        return true

    onBlur: (e)=>
        @emitEvent "blur", [e]
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

    constructor: (InputField, @tableName, @columns, options) ->

        config =
            rowHeight : 24
            numRows   : 10

        @elInputField = $(InputField)

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

        posTop     = @elInputField.position().top
        posLeft    = @elInputField.position().left

        width      = @elInputField.outerWidth(true)
        height     = @elInputField.outerHeight(true)

        $.extend config, options

        @win = new FloatingSelect(posLeft + scrollLeft, posTop+scrollTop+height, width, config.rowHeight*config.numRows)
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
            rowHeight   : 24
            numRows     : 10
            showHeaders : false
            width       : null
            height      : null
            render      : null
            placeholder : "Select an option"

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

        posTop     = @elInputField.position().top
        posLeft    = @elInputField.position().left

        width      = @elInputField.outerWidth(true)
        height     = @elInputField.outerHeight(true)
        if !@config.width?  then @config.width = width
        if !@config.height? then @config.height = @config.rowHeight*@config.numRows

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

