####
#
# NOTE:  Nothing in here works currently, moving to new chart system
#
####

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

    ##|
    ##|  Add basic chart with prepoulated data
    addTestButton "Basic Chart with lazy load", "Open", ()->

        addHolder("renderTest1");
        earthQuakeData = [
            {
                x: new Date(2011,12)
                y: 450
            },
            {
                x: new Date(2012,'01')
                y: 300
            },
            {
                x: new Date(2012,'02')
                y: 350
            }
        ]
        ##| need to load CanvasJS if its not available at window.CanvasJs
        ##| also this loading is optional if you create call constructor of Chart
        ##| it will automatically try to load the canvas js
        Chart.loadJs()
            .then () ->
                ##| here on creation of object it will try to load canvas js if not available
                chart = new LineChart("renderTest1","Another EarthQuake Chart")
                chart
                    .setOptions
                        backgroundColor: "#f5f5f5"
                    .xAxis
                        valueFormatString: "MMM",
                        interval:1,
                        intervalType: "month"
                    .yAxis
                        includeZero: false
                    .setCalculated(earthQuakeData)
                    .render()
        ## withData can be called multiple times it will push each type in the data array of chart
        true

    addTestButton "Chart with datamap table", "Open", ()->

            addHolder("renderTest1");
            Chart.loadJs()
                .then () ->
                    ##| here on creation of object it will try to load canvas js if not available
                    chart = new BarChart("renderTest1","Zipcodes Per State")
                    chart
                        .addTable "zipcode"
                        .setOptions
                            backgroundColor: "#f5f5f5"
                        .xAxis
                            title: "States"
                            valueFormatString: "string"
                        .yAxis
                            title: "Zipcode Counts"
                            includeZero: false
                        .filter (row) ->
                            ## filter rows which has state NY or MA
                            ## for example to include only rows with NY, MA, NH state
                            ## ['NY','MA','NH'].indexOf(row.state) != -1
                            true
                        .calculate (row, currentDataSet) ->
                            ##| current processing row and previous calculated result is passed
                            ##| here we return the new result which will become previous result for the next iteration
                            ##| previous result will be array of objects containing x and y value for chart
                            nyPoint = currentDataSet.filter (p) -> p.label == row.state
                            ##| if point for row.state not found (if first iteration for NY)
                            if( ! nyPoint.length )
                                nyPoint =
                                    label: row.state
                                    y: 1
                                currentDataSet.push nyPoint
                            else
                                ##| if point found then we increase its value and return
                                nyPoint = nyPoint.pop();
                                currentDataSet[currentDataSet.indexOf(nyPoint)].y++
                            return currentDataSet
                        .render()
            ## withData can be called multiple times it will push each type in the data array of chart
            true


    go()
