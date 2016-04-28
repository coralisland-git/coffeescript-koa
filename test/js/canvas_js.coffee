$ ->

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
                chart = new Chart("renderTest1","Another EarthQuake Chart")
                chart
                    .xAxis
                        valueFormatString: "MMM",
                        interval:1,
                        intervalType: "month"
                    .yAxis
                        includeZero: false
                    .withData earthQuakeData # optionally type can be 2nd args
                    .render()
        ## withData can be called multiple times it will push each type in the data array of chart
        true


    go()
