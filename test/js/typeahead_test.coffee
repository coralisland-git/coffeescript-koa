

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

    template = '''
        <br>
        <div class='testInput1'>
            <input name='testCity' id='testCity' width='150'>
        </div>
        <br>

        <div id='ptestMenu1' style='width: 140px;'></div>
        <br>

        <div id='ptestMenu2' style='width: 140px;'></div>
        <br>

        <div id='ptestMenu3' style='width: 260px;'></div>
        <br>
    '''

    loadZipcodes()
    .then ()->

        result = DataMap.addColumn "test",
            name   : "options"
            source : "options"

        result = DataMap.addColumn "test",
            name   : "options2"
            source : "options2"

        $("#testCase").html template

        Words = [ "Apple", "Ball", "Bat", "Bath", "Car", "Dog", "Double", "Big Dog", "Bath House", "Ball Boy", "Dog Track", "Tracking", "Simple", "Zebra", "Cow","Horse","Pig","Snake"]
        DataMap.setDataCallback "test", "findAll", (condition)->
            results = []
            results.push { id: word } for word in Words
            return results

        DataMap.setDataCallback "test", "findFast", (id, subkey)->
            return id

        ##|
        ##|  Simple typeahead example

        t = new TypeaheadInput("#testCity", "test", [ "options" ])
        t.on "change", (val)->
            console.log "TypeaheadInput #1:", val

        ##|
        ##|  Example 2 - Using zipcode data with a custom width and table headers

        t = new TableDropdownMenu("#ptestMenu1", "test", [ "options" ])
        t.on "change", (val)->
            console.log "TableDropdownMenu #1:", val

        options =
            width: 500
            showHeaders: true

        t = new TableDropdownMenu("#ptestMenu2", "zipcode", [ "id", "code", "city", "state" ], options)
        t.on "change", (val)->
            console.log "TableDropdownMenu #2:", val


        ##|
        ##|  Example 3 - Using the Zipcode data with a custom render function

        options.render = (id, row)=>
            console.log "render[#{id}]", row
            return row.city + ", " + row.state + " - " + row.code

        options.placeholder = "Select a location"

        t = new TableDropdownMenu("#ptestMenu3", "zipcode", [ "id", "code", "city", "state" ], options)
        t.on "change", (val)->
            console.log "TableDropdownMenu #2:", val

