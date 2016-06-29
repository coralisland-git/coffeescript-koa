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
            table.render()
            true
        go()
