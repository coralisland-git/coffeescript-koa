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

    addTestButton "Render table", "Open", ()->

        addHolder("renderTest1");
        table = new TableView $("#renderTest1")
        table.addTable "zipcode"
        table.render()
        table.updateRowData()
        true

    addTestButton "Render table 2", "Open", ()->

        addHolder("renderTest1");
        table = new TableView $("#renderTest1")
        noAreaCode = (col)  -> col.name != "Area Code"
        filter = (obj, key) -> obj.county == "HAMPDEN"
        table.sort = (a, b) ->

            aa = DataMap.getDataField("zipcode", a.key, "city")
            bb = DataMap.getDataField("zipcode", b.key, "city")
            if aa < bb then return -1
            if aa > bb then return 1
            return 0

        table.addTable "zipcode", noAreaCode, filter
        table.render()
        table.updateRowData()
        true

    addTestButton "Configure Columns", "Open", ()->

        addHolder("renderTest1");
        table = new TableView $("#renderTest1")
        table.addTable "zipcode"
        table.allowCustomize()
        table.real_render()
        true

    addTestButton "Custom Column", "Open", ()->

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

        addHolder("renderTest1");
        table = new TableView $("#renderTest1")
        table.addTable "zipcode"
        table.real_render()
        true

    addTestButton "Grouping Columns", "Open", () ->
        addHolder("renderTest1")
        $('#renderTest1').height(400); ##| to add scroll the height is fix
        table = new TableView $("#renderTest1"), true
        table.addTable "zipcode"
        table.setFixedHeaderAndScrollable()
        table.groupBy("county")
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

        table.render()
        true


    addTestButton "Join Table", "Open", ()->

        addHolder("renderTest1");
        table = new TableView $("#renderTest1")
        table.addTable "zipcode"
        #table.addJoinTable "county", null, "county"
        table.real_render()
        true

    addTestButton "Checkboxes", "Open", ()->

        addHolder("renderTest1");
        table = new TableView $("#renderTest1"), true
        table.addTable "zipcode"
        table.real_render()
        true

    go()
