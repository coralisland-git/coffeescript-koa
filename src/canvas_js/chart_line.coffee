##| Chart Widget to add chart using canvasJS
##|
##| @extends Chart
##| example usage:
##| c = new LineChart("renderItemId", "title of the chart")
##| c.withData()
##|
class LineChart extends Chart

    ## ----------------------------------------------------------------------------------------------------------------
    ## function to render the chart using the calculated data
    ##
    ##
    render: () ->
        if !@calculatedData.length
            throw new Error "calculated data not found! please perform calculation to provide chart data"
        ##| the type of chart is specified
        @withData @calculatedData, 'line'
        super()
