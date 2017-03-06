$ ->
    TESTRESULT = {}
    new Promise (resolve, reject)->
        $.get "js/test_data/test_result.json", (allData)->
            TESTRESULT = allData.TESTRESULT
            resolve(true)
    addTestButton "Automatic Data from JSON", "Open", ()->

        Data = TESTRESULT

        DataMap.setDataTypesFromObject "results", Data
        DataMap.importDataFromObjects "results", Data

        addHolder("renderTest1");
        $("#renderTest1").height(500)

        table = new TableView $("#renderTest1")
        table.setFixedHeaderAndScrollable();
        table.addTable "results"
        table.setColumnFilterAsPopup "T197_UNT_PAK_ID"
        table.setColumnFilterAsPopup "T026_VEL_ID"
        table.setColumnFilterAsPopup "T231_ITM_STS_CD"
        table.render()

        console.log "Done"

        true

    go()
