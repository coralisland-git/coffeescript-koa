$ ->
    ##|
    ##|  This is just for diagnostics,  you don't need to verify the data map is
    ##|  loaded normally.  The data types should be loaded upon startup.
    addTest "Confirm Zipcodes datatype loaded", () ->
        dm = DataMap.getDataMap()
        if !dm? then return false

        zipcodes = dm.types["zipcode"]
        if !zipcodes? then return false
        if !zipcodes.col["code"]? then return false

        true

    ##|
    ##|  Load the zipcodes JSON file.
    ##|  This will insert the zipcodes into the global data map.
    addTest "Loading Zipcodes", () ->

        new Promise (resolve, reject) ->
            ds  = new DataSet "zipcode"
            ds.setAjaxSource "/js/test_data/zipcodes.json", "data", "code"
            ds.doLoadData()
            .then (dsObject)->
                resolve(true)
            .catch (e) ->
                console.log "Error loading zipcode data: ", e
                resolve(false)

    addTestButton "Render table - Simplest Example", "Open", ()->

        addHolder()
        .setView "Table", (view)->
            table = view.addTable "zipcode"

        true

    addTestButton "Render table - Sort and Filter function to hide Areacode", "Open", ()->

        addHolder()
        .setView "Table", (view)->

            noAreaCode = (col)  -> col.name != "Area Code"
            filter = (obj, key) -> obj.county == "HAMPDEN"
            table = view.addTable "zipcode", noAreaCode, filter
            table.sort = (a, b) ->

                aa = DataMap.getDataField("zipcode", a.key, "city")
                bb = DataMap.getDataField("zipcode", b.key, "city")
                if aa < bb then return -1
                if aa > bb then return 1
                return 0



        true

    addTestButton "Custom Column - Zipcode has a custom render function", "Open", ()->

        DataMap.setDataTypes "zipcode", [
            name    : "Custom"
            source  : "code"
            visible : true
            type    : "text"
            width   : 300
            render  : (val, tableName, fieldName) ->
                path = tableName + '/' + fieldName
                return "{" + path + "} = " + val
        ]

        addHolder()
        .setView "Table", (view)->
            table = view.addTable "zipcode"

        true

    addTestButton "Grouping Columns and adding action column 'Run'", "Open", () ->

        addHolder()
        .setView "Table", (view)->
            table = view.addTable "zipcode"
            table.groupBy("county")
            # table.groupBy("city")
            table.addActionColumn
                name    : "Run"
                width   : 80
                callback: (row)=>
                    console.log "Zipcode action column selected row:", row

        true

    addTestButton "Checkboxes", "Open", ()->

        addHolder()
        .setView "Table", (view)->
            table = view.addTable "zipcode"
            table.setEnableCheckboxes(true)

    addTestButton "Set Title Simple case", "Open", ()->

        addHolder()
        .setView "Table", (view)->
            table = view.addTable "zipcode"
            table.setTitle("Zipcode")
    
    addTestButton "Set Title: Grouping Columns", "Open", () ->

        addHolder()
        .setView "Table", (view)->
            table = view.addTable "zipcode"
            table.groupBy("county")
            view.setTitle "Zipcode Table"
        true

    go()
