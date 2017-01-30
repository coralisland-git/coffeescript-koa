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
        city   : "Manchester_changed_1"
        state  : "NH_other1"
        county : "HILLSBOROUGH_changed_1"
        lat    : "13.512632"
        lon    : "-18.325879"

    zipcodeData2 =
        code   : "03105"
        city   : "Manchester_changed_2"
        state  : "NH_other2"
        county : "HILLSBOROUGH_changed_2"
        lat    : "25.654258"
        lon    : "-20.545310"

    zipcodeData3 =
        code   : "03105"
        city   : "Manchester_changed_3"
        state  : "NH_other3"
        county : "HILLSBOROUGH_changed_3"
        lat    : "32.365845"
        lon    : "-33.225304"

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

    
    ##|
    ##|  Load the JSON files.
    ##|  This will insert the zipcodes, SaveZipcodeData and testData into the global data map.
    addTest "Loading Data from files..", () ->
        loadZipcodes()
        loadDatafromJSONFile "SaveZipcodeData"
        loadDatafromJSONFile "testData"
        true

    addTest "Confirm DataMap Loaded", ()->

        dm = DataMap.getDataMap()
        if dm?.types["zipcode"]?.col["code"]? then return true
        
        false
    
    addTestButton "Bind to Path(Only One Data Field)", "Open", () =>
        addHolder "renderTest"
        wdt = new WidgetTag("div", null, "wdt_div")
        wdt.bindToPath "zipcode", "03105", "city"
        $("#renderTest").append($ "<br><span>Simple Data Field, you can edit it</span>")
        $("#renderTest").append wdt.getTag()
        
        true

    addTestButton "Bind to Path(Several Widgets with same Path)", "Open", () =>
        addHolder "renderTest"
        wdt_1 = new WidgetTag("div", null, "wdt_1")
        wdt_2 = new WidgetTag("div", null, "wdt_2")
        wdt_3 = new WidgetTag("div", null, "wdt_3")
        wdt_1.bindToPath "zipcode", "03105", "city"
        wdt_2.bindToPath "zipcode", "03105", "city"
        wdt_3.bindToPath "zipcode", "03105", "city"
        $("#renderTest").append $ "<p>Three WidgetTags with same DataPath, if one changes, others are updated automatically. </p>"
        $("#renderTest").append wdt_1.getTag()
        $("#renderTest").append wdt_2.getTag()
        $("#renderTest").append wdt_3.getTag()
        true

    addTestButton "Bind to Path(Editable and non-Editable fields)", "Open", () =>
        addHolder "renderTest"
        wdt_editable = new WidgetTag("div", null, "wdt_editable")
        wdt_noeditable = new WidgetTag("div", null, "wdt_noeditable")
        wdt_editable.bindToPath "testData", "0011", "Current Price"
        wdt_noeditable.bindToPath "testData", "0011", "id"
        $("#renderTest").append($ "<br><span>Editable Field</span>")
        $("#renderTest").append wdt_editable.getTag()
        $("#renderTest").append($ "<br><span>Non-editable Field</span>")
        $("#renderTest").append wdt_noeditable.getTag()
        return true

    addTestButton "Bind to Path(Several Data types)", "Open", () =>
        addHolder "renderTest"
        wdt_id = new WidgetTag("td", null, "wdt_td_id")
        wdt_id.bindToPath "testData", "0011", "id"

        wdt_initPrice = new WidgetTag("td", null, "wdt_td_initPrice")
        wdt_initPrice.bindToPath "testData", "0011", "Initial Price"

        wdt_curPrice = new WidgetTag("td", null, "wdt_td_curPrice")
        wdt_curPrice.bindToPath "testData", "0011", "Current Price"

        wdt_date = new WidgetTag("td", null, "wdt_td_date")
        wdt_date.bindToPath "testData", "0011", "Date"

        wdt_distance = new WidgetTag("td", null, "wdt_td_distance")
        wdt_distance.bindToPath "testData", "0011", "Distance"

        wdt_isNew = new WidgetTag("td", null, "wdt_td_isNew")
        wdt_isNew.bindToPath "testData", "0011", "IsNew"
       
        $("#renderTest").append($ "<br><table class='test_table_2'><caption>There are many data types you can bind to fields.</caption></table>")
        $(".test_table_2").append wdt_id.getTag()
        $(".test_table_2").append wdt_initPrice.getTag()
        $(".test_table_2").append wdt_curPrice.getTag()
        $(".test_table_2").append wdt_date.getTag()
        $(".test_table_2").append wdt_distance.getTag()
        $(".test_table_2").append wdt_isNew.getTag()
        true

    addTestButton "Add data(to zipcode)", "Open", () =>

        r = DataMap.addData "zipcode", "03105", zipcodeData1
        if r? and r.id == "03105"
            #console.log "Added doc:", r
            return true
        console.log "Invalid return from adding data"
        return false

    addTestButton "Add another data(to zipcode)", "Open", () =>

        r = DataMap.addData "zipcode", "03105", zipcodeData2
        if r? and r.id == "03105"
            #console.log "Added doc:", r
            return true
        console.log "Invalid return from adding data"
        return false

    addTestButton "Add Data with Timer(to zipcode)", "Open", () =>
        setTimeout ->
            r = DataMap.addData "zipcode", "03105", zipcodeData3
        , 3000
        
        return false

    addTestButton "Change value", "Change Manchester to NewManchester", () =>

        # don't do this because it won't register the change
        # zipcodeData1.state = "CA"

        DataMap.addData "zipcode", "03105",
            city: "NewManchester"


    go()