class FloatingObjectWindow extends FloatingWindow

    close: ()=>
        if @table?
            @el.remove()
            delete @table

    setPath: (@path)=>

        parts = @path.split "/"
        data = DataMap.getDataField parts[1], parts[2], parts[3]
        newTableName = "#{parts[1]}_#{parts[3]}"
        console.log "Show data", data
        DataMap.addDataUpdateTable newTableName, parts[2], data

        GlobalClassTools.addEventManager(this)

        if !@table?
            @table = new TableViewDetailed(@el, false)
            @table.setFixedHeaderAndScrollable()
            @table.showGroupPadding = false
            @table.showResize       = false

            @table.addTable newTableName, (colName)=>
                return true

            @table.render()

        return @table


$ ->

    loadGeoset = ()->

        ##|
        ##|  Load the geosetfull data before the test begins
        new Promise (resolve, reject) ->

            $.get "/js/test_data/geoset_full.json", (data)=>
                for item in data
                    DataMap.addDataUpdateTable "geosetfull", item.set_id, item
                resolve(true)

            # .then (dsObject)->
            #     console.log "Loaded", dsObject
            #     resolve(true)
            # .catch (e) ->
            #     console.log "Error loading geosetfull data: ", e
            #     resolve(false)

    loadGeoset()
    .then ()->

        ##|
        ##|  Tests

        coords = { x: 500, y: 500 }

        win = new FloatingObjectWindow coords.x-240, coords.y-400, 480, 380, $("body")
        win.show()
        win.setPath "/geosetfull/22/import"

        # addHolder("renderTest1")
        # $('#renderTest1').height(400);
        # table = new TableView $("#renderTest1"), true
        # table.addTable "geosetfull"
        # table.setFixedHeaderAndScrollable()
        # # table.groupBy("county")
        # # table.groupBy("city")
        # table.addActionColumn
        #     name: "Run"
        #     callback: (row)=>
        #         console.log "geosetfull action column selected row:", row
        #     width: 80

        # table.render()
        # true
