class FloatingSelect extends FloatingWindow

    table        : null
    optionHeight : 24

    getOptionHeight: ()=>
        return @optionHeight

    destroy: ()=>
        if @table? then @table.destroy()
        delete @table
        super()
        return true

    hide: ()=>
        if @table? then @table.hide()
        super()
        return true

    show: ()=>
        super.show()
        @showTable()
        true

    onResize: ()=>
        true

    setTable: (@tableName, @columns, config)=>
        GlobalClassTools.addEventManager(this)

    showTable: ()=>
        if @table? then return @table

        @elHolder.setView "Table", (view)=>
            @table = view.addTable @tableName, (colName)=>
                ##|
                ##|  Column filter function only shows specific columns
                ##|
                if !@columns? then return true
                for opt in @columns
                    if opt == colName.getSource()
                        return true

                return false
            @table.showGroupPadding = false
            @table.showResize       = false
            @table.setAutoFillWidth()

            @table.on "click_row", (row, e)=>
                @emitEvent "select", [ row ]
                true

            @table.on "focus_cell", (path, item)=>
                console.log "on focus cell:", path, item
                @emitEvent "preselect", [ item.id, item ]
                true

            if config? and config.showHeaders
                @table.showHeaders = true

        true