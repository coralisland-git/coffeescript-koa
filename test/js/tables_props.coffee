$ ->

    loadProps = ()->

        ##|
        ##|  Load the zipcode data before the test begins
        new Promise (resolve, reject) ->

            $.get "/js/test_data/Props.json", (allData)->
                for rec in allData
                    DataMap.addDataUpdateTable "prop", rec.id, rec
                resolve(true)

    popupTest = ()->
        popup = new PopupTable "prop", "Zipcode table popup", 50, 50, 500, 300

    loadProps()
    .then ()->

        # popupTest()

        addHolder("renderTest1")
        $('#renderTest1').height(800); ##| to add scroll the height is fix
        table = new TableView $("#renderTest1"), true
        table.addTable "prop"
        table.setStatusBarEnabled(true)
        table.setFixedHeaderAndScrollable()

        table.currentFilter =
            prop:
                class_key: "3"

        # DataMap.changeColumnAttribute "prop", "city", "render", (val, row)=>
        #     console.log "Render city val=", val, "row=", row
        #     return "City"

        table.render()
        true

