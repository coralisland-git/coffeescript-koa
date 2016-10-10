$ ->

    loadZipcodes = ()->

        ##|
        ##|  Load the zipcode data before the test begins
        new Promise (resolve, reject) ->

            $.get "/js/test_data/SaveZipcodeData.json", (allData)->

                counter = 0
                for rec in allData

                    rec.zipcode = rec.id
                    rec.id = "Z"+rec.id.toString()
                    for varName, value of rec
                        if typeof value == "string" and value.length == 24 and value.charAt(10) == 'T' and value.charAt(23) == 'Z'
                            rec[varName] = new Date(value)

                    DataMap.addDataUpdateTable "zipcode", rec.id, rec

                resolve(true)

    loadZipcodes()
    .then ()->

        ##|
        ##|  Tests

        addHolder("renderTest1")
        $('#renderTest1').height(600); ##| to add scroll the height is fix
        table = new TableView $("#renderTest1"), true
        table.addTable "zipcode"
        table.setStatusBarEnabled(true)
        table.setFixedHeaderAndScrollable()
        table.addLock("Z28216")
        # table.groupBy("state")
        table.addSortRule("Active", -1)
        table.render()

        # table.groupBy("city")
        # table.addActionColumn
        #     name: "Run"
        #     source: "id"
        #     callback: (row)=>
        #         console.log "Zipcode action column selected row:", row
        #     # render: (currentValue, tableName, colName, id)=>
        #     #     console.log "c=", currentValue, "t=", tableName, "c=", colName
        #     #     return "[" + id + "]"
        #     width: 80

        # DataMap.changeColumnAttribute "zipcode", "city", "render", (val, row)=>
        #     console.log "Render city val=", val, "row=", row
        #     return "City"


        true
