$ ->

    demoMode = 0

    zipcodeTableTest1 = ()->

    startDemo = (dm)->

        demoMode = dm
        $("#testCase").html ""

        dtc = new DataTypeCollection "ZipcodeTable", TableConfigZipcodes

        ds  = new DataSet "zipcodes", dtc
        ds.setAjaxSource "/test/js/test_data/zipcodes.json", "data", "code"
        ds.doLoadData()
        .then (data) ->

            table = new TableView("#testCase", null, "code")
            table.configureColumns TableConfigZipcodes, "Zipcodes"

            for code, o of data
                table.addRow o

            table.render()

        true

    addTestButton "Open without save data", "Open", ()->
        startDemo(0)

    go()



