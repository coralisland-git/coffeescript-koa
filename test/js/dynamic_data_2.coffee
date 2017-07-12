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
        .scrollcontent {
            height: 100%;
        }
        </style>
    '''

    demoMode = 0

    TableZipcode = []
    TableZipcode.push
        name        : 'Code'
        source      : 'code'
        visible     : true
        editable    : false
        type        : 'int'
        required    : true

    TableZipcode.push
        name        : 'City'
        source      : 'city'
        visible     : true
        editable    : true
        type        : 'text'
        
    TableZipcode.push
        name        : 'State'
        source      : 'state'
        visible     : true
        editable    : false
        type        : 'text'
        
    TableZipcode.push
        name        : 'County'
        source      : 'county'
        visible     : true
        editable    : false
        type        : 'text'

    TableZipcode.push
        name        : 'Latitude'
        source      : 'lat'
        visible     : true
        editable    : true
        type        : 'float'

    TableZipcode.push
        name        : 'Longitude'
        source      : 'lon'
        visible     : true
        editable    : true
        type        : 'float'

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

    TableTestdata = []
    TableTestdata.push
        name        : "ID"
        source      : "id"
        editable    : false
        required    : true
    TableTestdata.push
        name        : "InitialPrice"
        source      : "initialPrice"
        editable    : false
    TableTestdata.push
        name        : "CurrentPrice"
        source      : "currentPrice"
        editable    : true
    TableTestdata.push
        name        : "Date"
        source      : "date"
        editable    : true
    TableTestdata.push
        name        : "Distance"
        source      : "distance"
        editable    : true
    TableTestdata.push
        name        : "IsNew"
        source      : "isNew"
        editable    : true
    TableTestdata.push
        name        : "ImageList"
        source      : "imagelist"
        editable    : true

    testData1 =
        "id"            :   "0011"
        "initialPrice" :   5000.00,
        "currentPrice" :   4999.99,
        "date"          :   "2017-01-16",
        "distance"      :   1000,
        "isNew"         :   true
        "ImageList"     :   "./js/test_Data/images/1.jpg"

    
    ##|
    ##|  Load the JSON files.
    ##|  This will insert the zipcodes and testData into the global data map.
    addTest "Loading Data from files..", () ->
        loadZipcodes()
        .then ()->
            DataMap.setDataTypes 'zipcode', TableZipcode
            return true

        loadDatafromJSONFile "testData"
        .then ()->
            DataMap.setDataTypes 'testData', TableTestdata
            return true

        true

    addTest "Confirm DataMap Loaded", ()->

        dm = DataMap.getDataMap()
        if dm?.types["zipcode"]?.col["code"]? then return true
        
        false
    
    addTestButton "Bind to Path(Only One Data Field)", "Open", () =>
        viewExe = addHolder()
        wdt1 = viewExe.add("div", "", "wdt_div1")
        wdt1.html("<br><span>Simple Data Field, you can edit it</span>")
        wdt2 = viewExe.add("div", "", "wdt_div2")
        wdt2.bindToPath "zipcode", "03105", "city"
        true

    addTestButton "Bind to Path(Several Widgets with same Path)", "Open", () =>
        viewExe = addHolder()
        wdt_1 = viewExe.add("div", "", "wdt_1")
        wdt_2 = viewExe.add("div", "", "wdt_2")
        wdt_3 = viewExe.add("div", "", "wdt_3")
        wdt_1.bindToPath "zipcode", "03105", "city"
        wdt_2.bindToPath "zipcode", "03105", "city"
        wdt_3.bindToPath "zipcode", "03105", "city"
        true

    addTestButton "Bind to Path(Editable and Uneditable fields)", "Open", () =>
        viewExe = addHolder()
        wdt_lblEdit = viewExe.addDiv("", "wdt_lblEdit")
        wdt_lblEdit.html "<br><span>Editable Field</span>"
        wdt_editable = viewExe.add("div", "", "wdt_editable")
        wdt_lblNoEdit = viewExe.addDiv("", "wdt_lblNoEdit")
        wdt_lblNoEdit.html "<br><span>Uneditable Field</span>"
        wdt_uneditable = viewExe.add("div", "", "wdt_uneditable")
        wdt_editable.bindToPath "zipcode", "03105", "city"
        wdt_uneditable.bindToPath "zipcode", "03105", "county"
        return true

    addTestButton "Bind to Path(Several Data types)", "Open", () =>
        viewExe = addHolder()
        wdt_table = viewExe.add("table", "test_table", "wdt_table")
        wdt_table.html "<caption>There are many data types you can bind to data fields.(Here, except first 2 columns, all are editable.)</caption>"
        wdt_id = wdt_table.add("td", null, "wdt_td_id")
        wdt_id.bindToPath "testData", "0011", "id"

        wdt_initPrice = wdt_table.add("td", null, "wdt_td_initPrice")
        wdt_initPrice.bindToPath "testData", "0011", "initialPrice"

        wdt_curPrice = wdt_table.add("td", null, "wdt_td_curPrice")
        wdt_curPrice.bindToPath "testData", "0011", "currentPrice"

        wdt_date = wdt_table.add("td", null, "wdt_td_date")
        wdt_date.bindToPath "testData", "0011", "date"

        wdt_distance = wdt_table.add("td", null, "wdt_td_distance")
        wdt_distance.bindToPath "testData", "0011", "distance"

        wdt_isNew = wdt_table.add("td", null, "wdt_td_isNew")
        wdt_isNew.bindToPath "testData", "0011", "isNew"

        wdt_imagelist = wdt_table.add("td", null, "wdt_td_imagelist")
        wdt_imagelist.bindToPath "testData", "0011", "imagelist"
       
        #$("#renderTest").append($ "<br><table class='test_table_2'><caption>There are many data types you can bind to data fields.(Here, except first 2 columns, all are editable.)</caption></table>")
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