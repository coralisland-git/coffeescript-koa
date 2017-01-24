$ ->

    $("body").append '''
        <style type="text/css">
        .data {
            width  : 300px;
            border : 1px solid #bbbbdd;
            color  : #309030
        }
        .lastTable {
            margin-bottom : 330px;
        }
        </style>
    '''

    demoMode = 0

    zipcodeData1 =
        code   : "03105"
        city   : "Manchester_other1"
        state  : "NH_other1"
        county : "HILLSBOROUGH_other1"
        lat    : "42.952124"
        lon    : "-71.653939"

    zipcodeData2 =
        code   : "03105"
        city   : "Manchester_other2"
        state  : "NH_other2"
        county : "HILLSBOROUGH_other2"
        lat    : "42.952124"
        lon    : "-71.653939"

    saveZipcodeData1 = 
        "id":"00017",
        "Active":3,
        "Pending":1,
        "city":"Invalid",
        "state":"Invalid",
        "dateLastRently":"2016-10-06T17:57:17.988Z",
        "dateLastSchools":"2016-09-14T17:32:52.775Z"

    testData1 =
        "id": "0011"
        "Initial Price" :   5000.00,
        "Current Price" :   4999.99,
        "Date"          :   "2017-01-16",
        "Distance"      :   1000,
        "IsNew"         :   true

    addTest "Confirm DataMap Loaded", ()->

        dm = DataMap.getDataMap()
        if !dm? then return false

        zipcodes = dm.types["zipcode"]
        #console.log zipcodes
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
    ##|
    ##|  Load the SaveZipcodeData JSON file.
    ##|
    addTest "Loading SaveZipcodeData", () ->

        new Promise (resolve, reject) ->
            ds  = new DataSet "SaveZipcodeData"
            ds.setAjaxSource "/js/test_data/SaveZipcodeData.json", "", "id"
            ds.doLoadData()
            .then (dsObject)->
                resolve(true)
            .catch (e) ->
                console.log "Error loading SaveZipcode data: ", e
                resolve(false)

    addTest "Loading TestData", () ->
        new Promise (resolve, reject) ->
            ds = new DataSet "TestData"
            ds.setAjaxSource "/js/test_data/testData.json", "", "id"
            ds.doLoadData()
            .then (dsObject) ->
                resolve(true)
            .catch (e) ->
                console.log "Error loading TestData"
                resolve(false)
    
    addTestButton "Bind to Path", "Open", () =>
        wdt_tr = new WidgetTag("tr", null, "wdt_tr", null)
        wdt_tr.add "td", null, "wdt_td", null
        wdt_tr.add "td", null, "wdt_td", null
        wdt_tr.add "td", null, "wdt_td", null
        wdt_tr.add "td", null, "wdt_td", null
        wdt_tr.add "td", null, "wdt_td", null
        wdt_tr.add "td", null, "wdt_td", null
        children = wdt_tr.getChildren()

        index = 0
        for field, value of zipcodeData1
            console.log children[index]
            children[index]?.bindToPath "zipcode", "03105", field
            index++
 
        html = "<br><table class='test_table'><caption>Single Widget</caption></table><br>";
        $("#testCase").append($ html)
        $(".test_table").last().append wdt_tr.getTag()
        return true

    addTestButton "Bind to Path(Several Widgets)", "Open", () =>
        wdt_tr_1 = new WidgetTag("tr", null, "wdt_tr_1", null)
        wdt_tr_2 = new WidgetTag("tr", null, "wdt_tr_2", null)
        wdt_tr_3 = new WidgetTag("tr", null, "wdt_tr_3", null)
        for i in [0..5]
            wdt_tr_1.add "td", null, "wdt_td_1#{i}", null
            wdt_tr_2.add "td", null, "wdt_td_2#{i}", null
            wdt_tr_3.add "td", null, "wdt_td_3#{i}", null
        children_1 = wdt_tr_1.getChildren()
        children_2 = wdt_tr_2.getChildren()
        children_3 = wdt_tr_3.getChildren()

        index = 0
        for field, value of zipcodeData1
            children_1[index]?.bindToPath "zipcode", "03105", field
            children_2[index]?.bindToPath "zipcode", "03105", field
            children_3[index]?.bindToPath "zipcode", "03105", field
            index++
        html = "<p><br></p><table class='test_table_multiwidget'><caption>Here are several widgets with same path</caption></table><br>";
        $("#testCase").append($ html)
        $(".test_table_multiwidget").last().append wdt_tr_1.renderField()
        $(".test_table_multiwidget").last().append wdt_tr_2.renderField()
        $(".test_table_multiwidget").last().append wdt_tr_3.renderField()

        return true

    addTestButton "Add data(to zipcode)", "Open", () =>

        r = DataMap.addData "zipcode", "03105", zipcodeData1
        if r? and r.id == "03105"
            console.log "Added doc:", r
            return true
        console.log "Invalid return from adding data"
        return false

    addTestButton "Add another data(to zipcode)", "Open", () =>

        r = DataMap.addData "zipcode", "03105", zipcodeData2
        if r? and r.id == "03105"
            console.log "Added doc:", r
            return true
        console.log "Invalid return from adding data"
        return false

    addTestButton "Add Data with Timer(to zipcode)", "Open", () =>
        setTimeout ->
            r = DataMap.addData "zipcode", "03105", zipcodeData2
        , 3000
        if r?.id == "03105"
            console.log "Added(with timer) doc:", r
            return true
        console.log "Invalid return from adding data"
        return false

    addTestButton "Bind to Path(SaveZipcodeData)", "Open", () =>
        wdt_tr = new WidgetTag("tr", null, "wdt_tr", null)
        wdt_tr.add "td", null, "wdt_td", null
        wdt_tr.add "td", null, "wdt_td", null
        wdt_tr.add "td", null, "wdt_td", null
        wdt_tr.add "td", null, "wdt_td", null
        wdt_tr.add "td", null, "wdt_td", null
        wdt_tr.add "td", null, "wdt_td", null
        wdt_tr.add "td", null, "wdt_td", null
        children = wdt_tr.getChildren()

        index = 0
        for field, value of saveZipcodeData1
            console.log children[index]
            children[index]?.bindToPath "SaveZipcodeData", "00017", field
            index++
 
        html = "<br><table class='test_table_1'><caption>Single Widget from Table SaveZipcodeData</caption></table><br>";
        $("#testCase").append($ html)
        $(".test_table_1").last().append wdt_tr.getTag()
        $(".lastTable").removeClass "lastTable"
        $(".test_table_1").last().addClass "lastTable"
        return true

    addTestButton "Bind to Path(several Data types)", "Open", () =>
        wdt_tr = new WidgetTag("tr", null, "wdt_tr", null)
        wdt_tr.add "td", null, "wdt_td", null
        wdt_tr.add "td", null, "wdt_td", null
        wdt_tr.add "td", null, "wdt_td", null
        wdt_tr.add "td", null, "wdt_td", null
        wdt_tr.add "td", null, "wdt_td", null
        wdt_tr.add "td", null, "wdt_td", null
        children = wdt_tr.getChildren()
        index = 0
        for field, value of testData1
            children[index]?.bindToPath "TestData", "0011", field
            index++

        html = "<br><table class='test_table_2'><caption>Single widget from Table TestData</caption></table><br>"
        $("#testCase").append($ html)
        $(".test_table_2").last().append wdt_tr.getTag()
        $(".lastTable").removeClass "lastTable"
        $(".test_table_2").last().addClass "lastTable"
        true

    addTest "Render Property", () ->

        DataMap.addData "property", 1234,
            id: 1234
            address: "1234 Fake Street"
            pool: "Yes"
        wdt_tr = new WidgetTag("tr", null, "wdt_tr", null)
        wdt_tr.add "td", null, "wdt_td", null
        wdt_tr.add "td", null, "wdt_td", null
        wdt_tr.add "td", null, "wdt_td", null
        html = "<br>Three property table fields, id, address, pool <br><table id='test_tbl_fake'></table>";

        children = wdt_tr.getChildren()
        $("#testCase").append($ html)
        
        children[0].renderField "property", 1234, "id"
        children[1].renderField "property", 1234, "address"
        children[2].renderField "property", 1234, "pool"
        $("#test_tbl_fake").append wdt_tr.getTag()
        true

    addTestButton "Change value", "Change NH to CA", () =>

        # don't do this because it won't register the change
        # zipcodeData1.state = "CA"

        DataMap.addData "zipcode", "03105",
            state: "CA"

    go()


#