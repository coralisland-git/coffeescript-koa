$ ->

    addTestButton "Automatic Data from JSON", "Open", ()->

        Data = TESTRESULT

        DataMap.setDataTypesFromObject "results", Data
        DataMap.importDataFromObjects "results", Data

        addHolder("renderTest1");

        table = new TableView $("#renderTest1")
        table.fixedHeaderAndScrollable();
        table.addTable "results"
        # table.addInlineSortingSupport()
        table.render()

        console.log "Done"

        true

    go()