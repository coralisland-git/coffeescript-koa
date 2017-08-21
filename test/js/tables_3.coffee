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

        addHolder().setView "Table", (view) ->
            table = view.addTable "results"
            table.setColumnFilterAsPopup "T197_UNT_PAK_ID"
            table.setColumnFilterAsPopup "T026_VEL_ID"
            table.setColumnFilterAsPopup "T231_ITM_STS_CD"
            console.log "Done"  
        true

    go()
