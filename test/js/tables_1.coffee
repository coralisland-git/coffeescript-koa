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

        true

    addTestButton "Render table 2", "Open", ()->

        addHolder("renderTest1");
        table = new TableView $("#renderTest1"), true
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

        true

    addTestButton "Configure Columns", "Open", ()->

        addHolder("renderTest1");
        table = new TableView $("#renderTest1")
        table.addTable "zipcode"
        table.render()

        true

    addTestButton "Custom Column", "Open", ()->

        DataMap.setDataTypes "zipcode", [
            name    : "Custom"
            source  : "code2"
            visible : true
            type    : "text"
            width   : 300
            render  : (val, path) ->
                return "{" + path + "} = " + val
        ]

        addHolder("renderTest1");
        table = new TableView $("#renderTest1")
        table.addTable "zipcode"
        table.render()

        true


    addTestButton "Join Table", "Open", ()->

        addHolder("renderTest1");
        table = new TableView $("#renderTest1")
        table.addTable "zipcode"
        table.addJoinTable "county", null, "county"

        table.render()

        true

    addTestButton "Checkboxes", "Open", ()->

        addHolder("renderTest1");
        table = new TableView $("#renderTest1"), true
        table.addTable "zipcode"
        table.render()

        true

    addTestButton "context menu with sorting in header according to DataType", "Open", ()->
        addHolder("renderTest1");
        table = new TableView $("#renderTest1")
        table.addTable "zipcode"
        table.render()
        table.setupContextMenu()
        true
        
    addTestButton "auto hide columns from left on resize", "Open", ()->
        DataMap.setDataTypes "zipcode", [
            name    : "Custom-1"
            source  : "code1"
            visible : true
            type    : "text"
            width   : 300
            render  : (val, path) ->
                return "250px"
        ]
        DataMap.setDataTypes "zipcode", [
            name    : "hidden column1"
            source  : "code2"
            visible : true
            type    : "text"
            render  : (val, path) ->
                return "can hide"
        ]
        DataMap.setDataTypes "zipcode", [
            name    : "Hidden Column2"
            source  : "code3"
            visible : true
            type    : "text"
            render  : (val, path) ->
                return "hide"
        ]
        addHolder("renderTest1");
        table = new TableView $("#renderTest1")
        table.addTable "zipcode"
        table.render()
        #width can be dynamic as parameter | default = 32
        table.setAutoHideColumn()
        true

    addTestButton "simpleobject data type test", "Open", ()->
        ##| set the address as object in data map, to manipulate address field as simple object
        for key,obj of DataMap.getDataMap().data.zipcode
            obj.address = {city:obj.city,state:obj.state,country:obj.county}

        DataMap.setDataTypes "zipcode", [
            name    : "Address"
            source  : "address"
            visible : true
            type    : "simpleobject"
            width   : 200,
            options:
                compile: "{{city}}, {{state}}, {{country}}"
        ]
        addHolder("renderTest1");
        table = new TableView $("#renderTest1")
        table.addTable "zipcode"
        table.render()
        true

    addTestButton "dynamic add/remove row test case", "Open", ()->
        addHolder("renderTest1");
        table = new TableView $("#renderTest1")
        table.addTable "zipcode"
        table.render()
        _btnText = "&lt;input type='button' id='deleteFirstRow' class='btn btn-danger' style='margin-bottom:15px;' value='Delete First Row' /&gt;"
        _btnText = _btnText.replace('&lt;','<').replace('&gt;','>')
        $('#renderTest1').prepend _btnText
        _btnText = "&lt;input type='button' id='addNewRow' class='btn btn-success' style='margin-bottom:15px;' value='Add New Row' /&gt;"
        _btnText = _btnText.replace('&lt;','<').replace('&gt;','>')
        $('#renderTest1').prepend _btnText
        $('#addNewRow').on 'click', () ->
            ##| manipulate data
            _randomKey = Math.floor Math.random()*90000 + 10000
            _randomData = DataMap.getDataMap().data['zipcode']["0#{Math.floor Math.random() * (1344 - 1337 + 1) + 1337}"]
            if _randomData
                _randomData['code'] = _randomKey
            ##| add data
            DataMap.addData 'zipcode', _randomKey, _randomData
            ##| applyFilters to update new Data
            table.applyFilters()
        $('#deleteFirstRow').on 'click', () ->
            ##| get first row key from table to pass as arg in function
            _key = $('#renderTest1 tbody tr').first().find('.col_zipcode_code').text()
            ##| function to delete the data from dataMap and from screen
            DataMap.deleteDataByKey 'zipcode', _key
        true
    go()



