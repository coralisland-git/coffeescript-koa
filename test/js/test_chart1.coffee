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

    ##|
    ##|  popup window chart test
    ##|
    addTestButton "Column Chart in popup", "Open", ()->
        doPopupView 'DataChart','Column Chart', 'chart_popup', 1000, 450, (view) ->
            console.log view
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
            ##| flush chart so the clicking of test button second time, will render chart again
            ##| as popup html is removed once the popup is closed. that causes chart fail to render if existing instance is used.
            delete view.chart
        true

    ##|
    ##|  pie/donute chart
    ##|
    addTestButton "Pie/Donute Chart", "Open", ()->

        div = addHolderWidget("renderTest1")
        div.setView "DataChart", (view)=>
            view.setTitle("U.S Smartphone OS Market Share, Q3 2012").horizontalAlign = "center"
            view.chartOptions.animationEnabled = true
            view.chartOptions.zoomEnabled = true

            ds = new DataSeries()
            ds.setSeriesType "doughnut"
            ds.setLegend ''
            ds.fieldName = 'indexLabel'
            ds.addPoint "Android 53%", 53.37, "Android 53%"
            ds.addPoint "Apple iOS 35%", 35.0, "Apple iOS 35%"
            ds.addPoint "Blackberry 7%", 7, "Blackberry 7%"
            ds.addPoint "Windows Phone 2%", 2, "Windows Phone 2%"
            ds.addPoint "Others 5%", 5, "Others 5%"
            view.setData ds
            view.show()
        true

    ##|
    ##|  bubble chart
    ##|
    addTestButton "Bubble Chart", "Open", ()->

        div = addHolderWidget("renderTest1")
        div.setView "DataChart", (view)=>
            view.setTitle("Employment In Agriculture VS Agri-Land and Population").horizontalAlign = "center"
            view.chartOptions.animationEnabled = true
            view.chartOptions.zoomEnabled = true

            ds = new DataSeries 
                toolTipContent: "<span style='\"'color: {color};'\"'><strong>{name}</strong></span><br/><strong>Employment</strong> {x}% <br/> <strong>Agri Land</strong> {y} million sq. km<br/> <strong>Population</strong> {z} mn"
                type: "bubble"
            ds.fieldName = 'name'
            ds.addBubblePoint 39.6, 5.225, 1347, "China"
            ds.addBubblePoint 3.3, 4.17, 21.49, "Australia"
            ds.addBubblePoint 1.5, 4.043, 304.09, "US"
            ds.addBubblePoint 17.4, 2.647, 2.64, "Brazil"
            ds.addBubblePoint 8.6, 2.154, 141.95, "Russia"
            ds.addBubblePoint 52.98, 1.797, 1190.86, "India"
            ds.addBubblePoint 4.3, 1.735, 26.16, "Saudi Arabia"
            ds.addBubblePoint 1.21, 1.41, 39.71, "Argentina"
            ds.addBubblePoint 5.7, .993, 48.79, "SA"
            ds.addBubblePoint 13.1, 1.02, 110.42, "Mexico"
            ds.addBubblePoint 2.4, .676, 33.31, "Canada"
            ds.addBubblePoint 2.8, .293, 64.37, "France"
            ds.addBubblePoint 3.8, .46, 127.70, "Japan"
            ds.addBubblePoint 40.3, .52, 234.95, "Indonesia"
            ds.addBubblePoint 42.3, .197, 68.26, "Thailand"
            ds.addBubblePoint 31.6, .35, 78.12, "Egypt"
            ds.addBubblePoint 1.1, .176, 61.39, "U.K"
            ds.addBubblePoint 3.7, .144, 59.83, "Italy"
            ds.addBubblePoint 1.8, .169, 82.11, "Germany"
            view.setData ds
            view.axisX.setTitle "Employment - Agriculture"
            view.axisX.setFormatString "#0'%'"
            view.axisX.setRange 0, 100
            view.axisX.addOptions
                gridThickness: 1
                tickThickness: 1
                gridColor: "lightgrey"
                tickColor: "lightgrey"
                lineThickness: 0
            view.axisY.setTitle "Agricultural Land(sq.km)"
            view.axisY.setFormatString "#0'mn'"
            view.axisY.addOptions
                gridThickness: 1
                tickThickness: 1
                gridColor: "lightgrey"
                tickColor: "lightgrey"
                lineThickness: 0
            view.show()
        true

    go()