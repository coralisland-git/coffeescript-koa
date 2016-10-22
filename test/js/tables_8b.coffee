$ ->

    loadStockData()
    .then ()->

        addHolder("renderTest1");
        $("#renderTest1").css
            width   : 1000
            height  : 500
            padding : 0
            margin  : 0
            border  : "1px solid blue"

        table = new TableView $("#renderTest1")
        table.addTable "stocks"
        table.setFixedHeaderAndScrollable()
        table.moveActionColumn "distance"
        table.setStatusBarEnabled(true)
        table.render()

