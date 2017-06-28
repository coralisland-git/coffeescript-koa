
###
Example / Demo using 2 tables, one in each direction
###

$ ->

    addTest "Loading Zipcodes", ()->
        loadZipcodes()

	addTest "Add a single row in geoset table", () ->
        ## add the sample data to geoset table
        DataMap.addDataUpdateTable "geoset", "1",
            id: 1
            lastModified: '2016-04-20 10:10:00'
            title: 'sample Title'
            county: 'BERKSHIRE'
            dataset_type: 'Parcel'
            description: 'sample description'
            metro_area: 'Charlotte'
            source_url: 'http://maps.co.mecklenburg.nc.us/opendata/Parcel_TaxData.zip'
            total_points: 382725
            bbox: [
                '1449197.0931383073'
                '390084.8933570981'
                '1617626.7021882534'
                '533989.131004706'
            ]

    addTestButton "Simple Detailed Table", "Open", () ->
        addHolder()
        .setView "Table", (view)->
            view.setDetailed()
            view.addTable "zipcode"

    addTestButton "Simple Detailed Table GeoSet", "Open", () ->
        addHolder()
        .setView "Table", (view)->
            view.setDetailed()
            view.addTable "geoset"

    addTestButton "Table Detail View in popup", "Open", ()->

        doPopupView "Table", "Detailed Table Example", null, 400, 800, (view)->
            view.setDetailed()
            view.addTable "geoset"

    addTestButton "Dual Normal and Detailed with filter", "Open", ()->

        console.log "Creating a splitter with a normal table on the left and a detail view on the right."
        console.log "Right has minimum size of 300px"

        addHolder()
        .setView "Splittable", (splitter)->

            splitter.setPercent(60)
            splitter.getSecond().setMinWidth 300

            splitter.getFirst().setView "Table", (table)->
                table.addTable "zipcode", null, (row)->
                    row.id == '00544'

                table.setShowFilter(false)

                table.on "click_city", (row, e)=>
                    console.log "Table 1 - Click city:", row, " e=", e
                    return true

            splitter.getSecond().setView "Table", (table)->
                table.setDetailed()
                table.addTable "zipcode", null, (row)->
                    row.id == '00544'

                table.on "click_city", (row, e)=>
                    console.log "Table 2 - Click city:", row, " e=", e
                    return true

    go()
