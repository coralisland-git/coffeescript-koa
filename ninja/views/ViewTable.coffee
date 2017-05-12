class ViewTable extends View

    onSetupButtons: () =>

    onShowScreen: ()=>

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

        @on "resize", ()=>
            setTimeout @table.setHolderToBottom, 10

        return @table

