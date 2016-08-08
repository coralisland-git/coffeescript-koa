
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

    setTable: (@tableName, @columns)=>

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
                @emitEvent "preselect", [ item.currentValue ]
                true

            @table.setSimpleAndFixed()
            @table.render()

            ##|
            ##| Find first row
            if @table.rowDataRaw.length > 0 and @columns? and @columns.length > 0
                id  = @table.rowDataRaw[0].id
                col = @columns[0]
                @table.setFocusCell "/#{@tableName}/#{id}/#{col}"
                console.log "Focus to /#{@tableName}/#{id}/#{col}"


        return @table

class TypeaheadInput

    onKeypress: (e)=>
        val = @elInputField.val()
        if e.keyCode == 13
            @emitEvent "change", val
            @win.hide()
            return true

        if e.keyCode == 38
            @win.table.moveCellUp()
            return false

        if e.keyCode == 40
            if @win.table.focus?
                @win.table.moveCellDown()
            else
                @win.table.setFocusFirstCell()

            return false

        console.log "Keypress during input", e, e.keyCode, val
        @win.setFilter val
        return true

    onFocus: (e)=>
        @emitEvent "focus", [e]
        @win.show()
        return true

    onBlur: (e)=>
        @emitEvent "blur", [e]
        # @win.hide()
        return true

    constructor: (@elInputField, @tableName, @columns) ->

        ##|
        ##|
        GlobalClassTools.addEventManager(this)
        @elInputField.on "keyup", @onKeypress
        @elInputField.on "focus", @onFocus
        @elInputField.on "blur",  @onBlur

        scrollTop  = document.body.scrollTop
        scrollLeft = document.body.scrollLeft

        posTop     = @elInputField.position().top
        posLeft    = @elInputField.position().left

        width      = @elInputField.outerWidth(true)
        height     = @elInputField.outerHeight(true)

        @win = new FloatingSelect(posLeft + scrollLeft, posTop+scrollTop+height, width, 300)
        @win.setTable @tableName, @columns
        @win.on "select", (row)=>
            col = @columns[0]
            @elInputField.val(row[col])
            @emitEvent "change", row[col]
            @win.hide()

        @win.on "preselect", (value)=>
            @elInputField.val(value)