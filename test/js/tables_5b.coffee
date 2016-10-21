$ ->

    counties = {}

    loadCounties = ()->

        new Promise (resolve, reject)->

            $.get "/js/test_data/county_list.json", (allData)->

                for rec in allData.data
                    if rec.zipcode.length > 5 then continue
                    if /[0-9]/.test rec.county then continue
                    if /other/i.test rec.county then continue
                    reCounty = / County.*/
                    rec.county = rec.county.replace reCounty, ""

                    id = rec.zipcode.toString()
                    id = "0" + id while id.length < 5
                    id = "Z" + id

                    if !counties[id] then counties[id] = []
                    counties[id].push rec.county

                resolve(true)

    loadZipcodesStats = ()->


        ##|
        ##|  Load the zipcode data before the test begins
        new Promise (resolve, reject) ->

            $.get "/js/test_data/SaveZipcodeData.json", (allData)->

                counter = 0
                for rec in allData

                    rec.zipcode = rec.id
                    if rec.city == "Invalid" or rec.state == "Invalid" then continue

                    rec.id = "Z"+rec.id.toString()
                    for varName, value of rec
                        if typeof value == "string" and value.length == 24 and value.charAt(10) == 'T' and value.charAt(23) == 'Z'
                            rec[varName] = new Date(value)

                    delete rec[1]
                    delete rec[2]
                    delete rec[3]
                    delete rec[4]
                    delete rec[5]

                    rec.value = 0
                    # rec.counties = counties[rec.id.toString()]
                    # if !rec.counties?
                        # console.log "Missing counties for #{rec.id.toString()}"
                    DataMap.addDataUpdateTable "zipcode", rec.id, rec


                DataMap.changeColumnAttribute "zipcode", "value", "editable", true
                DataMap.changeColumnAttribute "zipcode", "value", "type", "number"
                DataMap.changeColumnAttribute "zipcode", "value", "width", 80

                DataMap.changeColumnAttribute "zipcode", "state", "visible", false

                resolve(true)

    loadCounties()
    .then ()->
        loadZipcodesStats()
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

        DataMap.changeColumnAttribute "zipcode", "Expired", "order", 10
        DataMap.changeColumnAttribute "zipcode", "Active", "order", 5

        # table.groupBy("city")
        table.addActionColumn
            name: "Run"
            source: "id"
            callback: (row)=>
                console.log "Zipcode action column selected row:", row
            # render: (currentValue, tableName, colName, id)=>
            #     console.log "c=", currentValue, "t=", tableName, "c=", colName
            #     return "[" + id + "]"
            width: 80

        # DataMap.changeColumnAttribute "zipcode", "city", "render", (val, row)=>
        #     console.log "Render city val=", val, "row=", row
        #     return "City"


        true
