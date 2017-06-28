class ViewPopupTable extends View

    onSetupButtons: () =>

    onShowScreen: ()=>

    ##
    ## function to set width and height of View
    ##
    setSize: (w, h)=>
        ## - xg
        if !@elHolder? then return false
        # console.log "TableView set size to #{w}, #{h}"
        if w > 0
            @elHolder.css "width", w
        if h > 0
            @elHolder.css "height", h

        true

    onResize: (w, h)=>
        if w == 0 or h == 0
            if @table? then @table.hide()
            return

        if globalDebugResize
            console.log "ViewTable ViewPopupTable onResize(#{w}, #{h})"

        @setSize w, h
        if @table
            @table.show()
            @table.onResize(w, h)

        true

    loadTable: (@tableName, vertical = false)=>

        @infoPanel = @elHolder.find(".infoPanel")
        @infoPanel.hide()
        if vertical
            @table = new TableViewDetailed @elHolder.find(".viewTableHolder")
        else
            @table = new TableView @elHolder.find(".viewTableHolder")

        @table.addTable @tableName
        @table.setFixedHeaderAndScrollable()
        @table.setStatusBarEnabled()
        @table.render()

        @table.updateRowData()

        return @table