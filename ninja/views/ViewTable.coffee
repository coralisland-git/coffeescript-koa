class ViewTable extends View

    onSetupButtons: () =>

    onShowScreen: ()=>

    ##|
    ##|  Add an action column (see TableView.coffee)
    addActionColumn: (data)=>
        @table.addActionColumn(data)
        @resetSize()
        true

    moveActionColumn: (columnName)=>
        @table.moveActionColumn(columnName)
        @resetSize()
        true

    setAutoFillWidth: ()=>
        if !@table?
            setTimeout @setAutoFillWidth, 100
            return

        @table.setAutoFillWidth(true)
        @resetSize()
        true

    ##|
    ##|  Show or hide the user input filters
    setShowFilter: (showFilters)=>
        if !@table?
            setTimeout @setShowFilter, 10, showFilters
            return true

        @table.showFilters = (showFilters == true)
        @resetSize()
        true

    ##
    ## function to set width and height of View
    ##
    setSize: (w, h)=>

        # if globalDebugResize
            # console.log @element, "ViewTable setSize(#{w}, #{h})"

        super(w, h)

        if @table
            @table.show()
            @table.onResize(w, h)

        true

    onResize: (w, h)=>

        super(w, h)

        if globalDebugResize
            console.log @element, "ViewTable onResize(#{w}, #{h})"

        if w == 0 or h == 0
            if @table? then @table.hide()
            return

        true

    getBadgeText: ()=>
        if !@table? then return null
        return @table.getTableTotalRows()

    ##|
    ##|  Make sure to call this before addTable/loadTable
    ##|  Display the table as a "Detailed" view
    ##|
    setDetailed: ()=>
        @isDetailed = true

    ##|
    ##|  simple add table function
    addTable: (@tableName, colFilterFunction, rowFilterFunction)=>

        @table = null

        if @isDetailed
            @table = new TableViewDetailed @el
        else
            @table = new TableView @el

        @table.addTable @tableName, colFilterFunction, rowFilterFunction
        @table.setFixedHeaderAndScrollable()
        @table.render()
        @table.setStatusBarEnabled()
        @table.updateRowData()

        return @table

    ##|
    ##|   Altername call name due to legacy code
    loadTable: (@tableName, colFilterFunction, rowFilterFunction)=>
        @addTable @tableName, colFilterFunction, rowFilterFunction

    ## gao
    groupBy: (columnName)=>
        @table.groupBy(columnName)
        @resetSize()
        true