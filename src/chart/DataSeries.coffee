class DataSeries

    constructor: (options)->

        @data =
            type:         "scatter"
            legendText:   "New DataSeries"
            showInLegend: false
            dataPoints:   []

    ##|
    ##|  Set the color for this series
    setColor: (newColor)=>
        @data.color = newColor

    setLegend: (newText)=>
        @data.legendText = newText
        @data.showInLegend = true
        true

    ##|
    ##|  Add a new point and increase the value if the point already exists
    ##|  @see http://canvasjs.com/editor/?id=http://canvasjs.com/example/gallery/column/oil_reserves/
    addAggregatePoint: (value, label)=>

        console.log "Adding #{value} to #{label}"
        for p in @data.dataPoints
            # if p.label == label
            if p.x.toString() == label.toString()
                p.y = (p.y || 0) + value
                return true

        point =
            y: value
            x: label
            # label: label

        @data.dataPoints.push(point)

    ##|
    ##|  Add a new point of data to the chart
    addPoint: (x, y)=>

        if @data.type == "column"
            point =
                y: y
                label: x
        else
            point =
                x: x
                y: y

        @data.dataPoints.push(point)
        return point

    ##|
    ##|  See CanvasJS Series types:
    ##|  http://canvasjs.com/
    setSeriesType: (newType)=>
        @data.type = newType
        true

    getData: ()=>
        return @data

    getDataPoints: ()=>
        return @data.dataPoints
