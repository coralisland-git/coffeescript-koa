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


