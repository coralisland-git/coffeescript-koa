class ViewTable extends View

    onSetupButtons: () =>

    onShowScreen: ()=>

    ##
    ## function to set width and height of View
    ##
    setSize: (w, h)=>
        ## - xg
        if !@elHolder? then return false
        console.log "TableView set size to #{w}, #{h}"
        if w > 0
            @elHolder.css "width", w
        if h > 0
            @elHolder.css "height", h

        ## To make tableView responsive when it is on PopupWindow
        #if @elHolder.height() > 0
        #    viewTableHolder = @elHolder.find ".viewTableHolder"
        #    viewTableHolder.height "100%"
        #else if @table?
        #    @table.onResize()

        true

    onResize: (w, h)=>
        @setSize w, h
        if @table
            @table.onResize()

    loadTable: (@tableName)=>

        @infoPanel = @elHolder.find(".infoPanel")
        @infoPanel.hide()

        @table = new TableView @elHolder.find(".viewTableHolder")

        @table.addTable @tableName
        @table.setFixedHeaderAndScrollable()
        @table.setStatusBarEnabled()
        @table.setHolderToBottom()
        @table.setParentView this
        @table.render()

        @table.updateRowData()
        #@on "resize", ()=>
        #    setTimeout @table.setHolderToBottom, 10

        return @table
