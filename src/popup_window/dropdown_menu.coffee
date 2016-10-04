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
