$ ->

    loadZipcodes = ()->

        ##|
        ##|  Load the zipcode data before the test begins
        new Promise (resolve, reject) ->
            ds  = new DataSet "zipcode"
            ds.setAjaxSource "/js/test_data/zipcodes.json", "data", "code"
            ds.doLoadData()
            .then (dsObject)->
                console.log "Loaded", dsObject
                resolve(true)
            .catch (e) ->
                console.log "Error loading zipcode data: ", e
                resolve(false)

    timerTest = ()->
        return

        counter = 0
        setInterval ()->
            counter++

            displayValue = DataMap.getDataFieldFormatted "zipcode", 1001, "city"
            value = DataMap.getDataField "zipcode", 1001, "city"
            console.log "display=", displayValue, " actual=", value

            DataMap.getDataMap().updatePathValueEvent "/zipcode/1001/city", "Test#{counter}"
            console.log "Setting /zipcode/01001/city", counter

        , 1000

    loadZipcodes()
    .then ()->

        ##|
        ##|  Tests

        addTest "Sorting, Fixed Header, Group By", ()->
            addHolder("renderTest1")
            $('#renderTest1').height(400); ##| to add scroll the height is fix
            table = new TableView $("#renderTest1"), true
            table.addTable "zipcode"
            table.setFixedHeaderAndScrollable()
            table.groupBy("county")
            table.addActionColumn "Run", (row)=>
                console.log "Zipcode action column selected row:", row

            timerTest()

            table.render()
            true
        go()
