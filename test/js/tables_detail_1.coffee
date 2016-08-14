
###
Example / Demo using 2 tables, one in each direction
###

$ ->

    new Promise (resolve, reject) ->
        ds = new DataSet "zipcode"
        ds.setAjaxSource "/js/test_data/zipcodes.json", "data", "code"
        ds.doLoadData()
        .then (dsObject)->
            resolve(true)
        .catch (e) ->
            console.log "Error loading zipcode data: ", e
            resolve(false)

    .then ()->

        addHolder("renderTest1");
        $("#renderTest1").css
            width: 1000
            height: 500
            padding: 0
            margin: 0
            "background" : "blue"
            "border": "1px solid green"

        table = new TableView $("#renderTest1")
        table.addTable "zipcode"
        table.setFixedHeaderAndScrollable()
        table.render (id)->
            if id is '00544' then return true
            return false
        table.on "click_city", (row, e)=>
            console.log "Table 1 - Click city:", row, " e=", e
            return true

        addHolder("renderTestSpace");
        $("#renderTestSpace").css
            width: "100%"
            height: 20

        addHolder("renderTest2");
        $("#renderTest2").css
            width: 1000
            height: 500
            padding: 0
            margin: 0
            "background" : "blue"
            "border": "1px solid green"

        table = new TableViewDetailed $("#renderTest2")
        table.addTable "zipcode"
        table.render (id)->
            if id is '00544' then return true
            return false
        table.on "click_city", (row, e)=>
            console.log "Table 2 - Click city:", row, " e=", e
            return true