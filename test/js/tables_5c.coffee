$ ->

    loadData = ()->
#

        ##|
        ##|  Load the zipcode data before the test begins
        new Promise (resolve, reject) ->

            $.get "/js/test_data/test_job.json", (allData)->

                console.profile("addingData");
                for rec in allData
                    DataMap.addDataUpdateTable "jobrun", rec.id, rec

                console.profileEnd("addingData");
                resolve(true)

    loadData()
    .then ()->

        ##|
        ##|  Tests
        addHolder("renderTest1")
        $('#renderTest1').height(400); ##| to add scroll the height is fix
        table = new TableView $("#renderTest1"), true
        table.addTable "jobrun"
        table.setStatusBarEnabled(true)
        table.setFixedHeaderAndScrollable()

        table.render()
        true
