$ ->

    TableRetsServer = []

    TableRetsServer.push
        name     : 'ID'
        source   : 'id'
        visible  : true
        editable : false
        type     : 'int'
        required : true
        width    : 40

    TableRetsServer.push
        name     : 'Modified'
        source   : '_lastModified'
        visible  : false
        editable : false
        type     : 'timeago'
        width    : 100

    TableRetsServer.push
        name     : "Active"
        source   : "active"
        type     : "boolean"
        width    : 60
        editable : true
        visible  : true

    TableRetsServer.push
        name     : "Title"
        source   : "server_name"
        type     : "text"
        editable : true
        visible  : true
        width    : 100

    TableRetsServer.push
        name     : "Username"
        source   : "username"
        type     : "text"
        editable : true
        visible  : true
        width    : 100

    TableRetsServer.push
        name     : "Password"
        source   : "password"
        type     : "text"
        editable : true
        visible  : false
        width    : 100

    TableRetsServer.push
        name     : "User Agent"
        source   : "useragent"
        type     : "enum"
        editable : true
        visible  : false
        width    : 80
        options  : ['RETS-Connector/1.2', 'OffMarket', 'Southcrest/1.0']

    TableRetsServer.push
        name     : "UA Password"
        source   : "useragent_password"
        type     : "text"
        editable : true
        visible  : false
        width    : 100

    TableRetsServer.push
        name     : "Verified"
        source   : "loginStatus"
        type     : "text"
        editable : true
        visible  : true
        width    : 60

    TableRetsServer.push
        name     : "Version"
        source   : "version"
        type     : "enum"
        editable : true
        visible  : false
        width    : 70
        options  : ['RETS/1.5', 'RETS/1.7.2']

    TableRetsServer.push
        name     : "Metro Area"
        source   : "metro_area"
        type     : "text"
        editable : true
        visible  : true
        width    : 70

    TableRetsServer.push
        name     : "Off Market"
        source   : "is_off_market"
        type     : "boolean"
        width    : 60
        editable : true
        visible  : true
        render: (val)=>
            console.log "Off Market Val:", val, typeof val
            if val then return "Yes"
            return "No"

    TableRetsServer.push
        name     : "Use POST"
        source   : "force_post"
        type     : "boolean"
        width    : 60
        editable : true
        visible  : true

    TableRetsServer.push
        name     : "Metadata Ver"
        source   : "metadataVersion"
        type     : "text"
        editable : false
        visible  : true
        width    : 80

    TableRetsServer.push
        name     : "Classes"
        source   : "classes"
        type     : "text"
        editable : false
        visible  : true
        width    : 60
        align: "right"
        render   : (val, obj)=>
            count = Object.keys(val).length
            return "#{count} <i class='fa fa-table'></i>"

    TableRetsServer.push
        name     : "URL"
        source   : "url"
        type     : "text"
        editable : true
        visible  : true
        width    : 100

    TableRetsServer.push
        name     : 'Total Active'
        source   : 'total_active'
        visible  : true
        editable : false
        type     : 'int'
        required : true
        width    : 70
        visible  : true

    TableRetsServer.push
        name     : 'Total Records'
        source   : 'total_properties'
        visible  : true
        editable : false
        type     : 'int'
        required : true
        width    : 70
        visible  : true

    ##| Configure the global map
    DataMap.setDataTypes "server", TableRetsServer

    loadServerData = ()->

        ##|
        ##|  Load the zipcode data before the test begins
        new Promise (resolve, reject) ->
            ds  = new DataSet "server"
            ds.setAjaxSource "/js/test_data/RetsData.json", null, "id"
            ds.doLoadData()
            .then (dsObject)->
                console.log "Loaded", dsObject
                resolve(true)
            .catch (e) ->
                console.log "Error loading RETS data: ", e
                resolve(false)

    loadServerData()
    .then ()->

        ##|
        ##|  Tests

        addTest "Sorting, Fixed Header, Group By", ()->
            addHolder("renderTest1")
            $('#renderTest1').height(2400); ##| to add scroll the height is fix
            table = new TableView $("#renderTest1"), true
            table.addTable "server"
            table.setFixedHeaderAndScrollable()
            table.render()

            table.on "click_classes", (row, e)=>
                console.log "Clicked Classes for ", row

            true
        go()
