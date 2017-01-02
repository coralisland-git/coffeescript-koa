$ ->

    ##|
    ##|  Simple canvasjs chart using this
    ##|  example: http://canvasjs.com/editor/?id=http://canvasjs.com/example/gallery/overview/label-on-axis/
    ##|
    addTestButton "Column Chart 1", "Open", ()->

        div = addHolderWidget("renderTest1")
        div.setView "DataChart", (view)=>
            view.setTitle("Test Title").horizontalAlign = "center"
            view.chartOptions.animationEnabled = true
            view.chartOptions.zoomEnabled = true

            ds = new DataSeries()
            ds.setSeriesType "column"
            ds.addPoint "banana", 18
            ds.addPoint "orange", 29
            ds.addPoint "apple", 40
            ds.addPoint "mango", 34
            ds.addPoint "grape", 24
            view.setData ds

            view.show()

    ##|
    ##|  Adding axis labels for testing
    ##|
    addTestButton "Column Chart w/ labels", "Open", ()->

        div = addHolderWidget("renderTest1")
        div.setView "DataChart", (view)=>
            view.setTitle("Test Title").horizontalAlign = "center"
            view.chartOptions.animationEnabled = true
            view.chartOptions.zoomEnabled = true

            ds = new DataSeries()
            ds.setSeriesType "column"
            ds.addPoint "banana", 28
            ds.addPoint "orange", 29
            ds.addPoint "apple", 40
            ds.addPoint "mango", 105
            ds.addPoint "grape", 2
            view.setData ds

            view.axisY.setTitle "Number eaten"
            view.axisX.setTitle "Type of fruit"
            view.show()


        true

    go()