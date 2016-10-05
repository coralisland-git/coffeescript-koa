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
        setTimeout @table.onResize, 10
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

