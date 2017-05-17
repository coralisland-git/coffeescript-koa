class ViewTable extends View

    onSetupButtons: () =>

    onShowScreen: ()=>

    ##
    ## function to set width and height of View
    ##
    setSize: (w, h)=>
        if !@elHolder? then return false
        console.log "TableView set size to #{w}, #{h}"
        if w > 0
            @elHolder.css "width", "100%"
        if h > 0
            @elHolder.css "max-height", "100%"

        ## - xg
        ## To make tableView responsive when it is on PopupWindow
        if @elHolder.height() > 0
            viewTableHolder = @elHolder.find ".viewTableHolder"
            viewTableHolder.height "100%"
        else 
            @table.onResize()

        true

    onResize: (w, h)=>
        @setSize w, h

    loadTable: (@tableName)=>

        @infoPanel = @elHolder.find(".infoPanel")
        @infoPanel.hide()

        @table = new TableView @elHolder.find(".viewTableHolder")
        @table.addTable @tableName
        @table.setFixedHeaderAndScrollable()
        @table.setStatusBarEnabled()
        @table.setHolderToBottom()
        @table.render()

        @table.updateRowData()
        @table.off "resize", @table.onResize
        @on "resize", ()=>
            setTimeout @table.setHolderToBottom, 10

        return @table
