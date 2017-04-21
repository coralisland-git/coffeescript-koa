class ViewPopupTable extends View

    onSetupButtons: () =>

    onShowScreen: ()=>

    onResize: (pw, ph)=>
        h = @elHolder.parent().parent().height()
        @table.elTableHolder.height h
        @table.render()
        true

    loadTable: (tableName, vertical=false) =>

        @popup.on "resize", @onResize

        @gid = GlobalValueManager.NextGlobalID()
        @tableHolder = $ "<div id='realPopupTable#{@gid}'></div>"
        @elHolder.html @tableHolder

        if vertical == false
            @table = new TableView @tableHolder
            @table.addTable tableName
            @table.setFixedHeaderAndScrollable()
            @onResize(0,0)
            
        if vertical == true
            @table = new TableViewDetailed @tableHolder
            @table.addTable tableName
            @onResize(0,0)        

        true
