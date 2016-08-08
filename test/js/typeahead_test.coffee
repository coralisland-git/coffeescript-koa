
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
        <style type="text/css">

        .floatingWindow
        {
            background-color: #e6e6e6;
        }

        </style>

        <div class='typeahead'>
            <input id='testCity' name='city' size='30' class='typeahead'>
        </div>
    '''

    loadZipcodes()
    .then ()->

        result = DataMap.addColumn "test",
            name   : "options"
            source : "options"

        result = DataMap.addColumn "test",
            name   : "options2"
            source : "options2"

        Words = [ "Apple", "Ball", "Bat", "Bath", "Car", "Dog", "Double", "Big Dog", "Bath House", "Ball Boy", "Dog Track", "Tracking", "Simple", "Zebra", "Cow","Horse","Pig","Snake"]
        DataMap.setDataCallback "test", "findAll", (condition)->
            results = []
            results.push { id: word } for word in Words
            return results

        DataMap.setDataCallback "test", "findFast", (id, subkey)->
            return id

        $("#testCase").append(template)
        city = $("#testCity")

        t = new TypeaheadInput(city, "test", [ "options" ])
        t.on "change", (val)->
            console.log "Selected:", val

