class ViewChart extends View

    getDependencyList: ()=>
        return []

    onSetupButtons: () =>

    onShowScreen: ()=>

    loadTable: (@tableName)=>

        @infoPanel = @elHolder.find(".infoPanel")
        @infoPanel.hide()

        @table = new TableView @elHolder.find(".viewTableHolder")
        @table.addTable @tableName
        @table.setFixedHeaderAndScrollable()
        @table.setStatusBarEnabled()
        @table.render()

        return @table
