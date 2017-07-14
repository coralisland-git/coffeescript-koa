$ ->

    testWithNewRows = !true


    delayAdd = (rec)->
        timeValue = Math.ceil(500000*Math.random())
        setTimeout ()->
            console.log "Adding row:", rec
            DataMap.addDataUpdateTable "zipcode", rec.code, rec
        , timeValue

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

        # popupTest()

        DataMap.getDataMap().updatePathValueEvent "/zipcode/02532/area_code", "TESTING"
        DataMap.changeColumnAttribute "zipcode", "area_code", "type", "memo"

        # DataMap.changeColumnAttribute "zipcode", "id", "visible", false

        addTest "Sorting, Fixed Header, Group By", ()->
            addHolder().setView "Table", (table)->
                table.addTable "zipcode"
                table.setAutoFillWidth()
                table.groupBy("county")
                timerTest()
                table.render()
            true
        go()
