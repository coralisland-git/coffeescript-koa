class DataSeries

    constructor: (options)->

        @data =
            type:         "scatter"
            color:        "#778899"
            legendText:   "New DataSeries"
            showInLegend: false
            dataPoints:   []

    addPoint: (x, y)=>
        point =
            x: x
            y: y
        @data.dataPoints.push(point)
        return point

    getData: ()=>
        return @data

    getDataPoints: ()=>
        return @data.dataPoints
