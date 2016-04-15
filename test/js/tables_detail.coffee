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

    addTestButton "Table Detail View", "Open", ()->

        addHolder("renderTest1");
        $("#renderTest1").width 250
        table = new TableViewDetailed $("#renderTest1")
        table.addTable "zipcode"
        table.render('00544')

        true
    go()
