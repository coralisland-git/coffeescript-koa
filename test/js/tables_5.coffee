$ ->

    testWithNewRows = true


    delayAdd = (rec)->
        timeValue = Math.ceil(500000*Math.random())
        setTimeout ()->
            console.log "Adding row:", rec
            DataMap.addDataUpdateTable "zipcode", rec.code, rec
        , timeValue

    loadZipcodes = ()->
#

        ##|
        ##|  Load the zipcode data before the test begins
        new Promise (resolve, reject) ->

            $.get "/js/test_data/zipcodes.json", (allData)->

                counter = 0
                for rec in allData.data
                    rec.Weather = "https://www.wunderground.com/cgi-bin/findweather/getForecast?query=pz:#{rec.code}&zip=1"
                    rec.love_it = new Date().getTime() % 2 == 1

                    if testWithNewRows and ++counter > 5
                        delayAdd(rec)
                    else
                        DataMap.addDataUpdateTable "zipcode", rec.code, rec

                resolve(true)

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

    popupTest = ()->
        popup = new PopupTable "zipcode", "Zipcode table popup", 50, 50, 500, 300

    loadZipcodes()
    .then ()->

        ##|
        ##|  Tests

        popupTest()

        DataMap.getDataMap().updatePathValueEvent "/zipcode/02532/area_code", "TESTING"
        DataMap.changeColumnAttribute "zipcode", "area_code", "type", "memo"

        DataMap.changeColumnAttribute "zipcode", "id", "visible", false

        addTest "Sorting, Fixed Header, Group By", ()->
            addHolder("renderTest1")
            $('#renderTest1').height(400); ##| to add scroll the height is fix
            table = new TableView $("#renderTest1"), true
            table.addTable "zipcode"
            table.setStatusBarEnabled(true)
            table.setFixedHeaderAndScrollable()
            table.groupBy("county")

            # table.groupBy("city")
            # table.addActionColumn
            #     name: "Run"
            #     source: "id"
            #     callback: (row)=>
            #         console.log "Zipcode action column selected row:", row
            #     # render: (currentValue, tableName, colName, id)=>
            #     #     console.log "c=", currentValue, "t=", tableName, "c=", colName
            #     #     return "[" + id + "]"
            #     width: 80

            # DataMap.changeColumnAttribute "zipcode", "city", "render", (val, row)=>
            #     console.log "Render city val=", val, "row=", row
            #     return "City"


            $("[data-id='38']").val("Beach")

            timerTest()

            table.render()
            true
        go()
