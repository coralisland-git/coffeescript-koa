##| Chart Widget to add chart using canvasJS
##|
##| @extends Chart
##| example usage:
##| c = new BarChart("renderItemId", "title of the chart")
##| c.withData()
##|
class BarChart extends Chart

    # @property [Array] tableRows total tablerows
    tableRows: []

    # @property [Array] calculated data to render inside chart
    calculatedData: []

    ## ----------------------------------------------------------------------------------------------------------------
    ## function to add the table data into line chart
    ##
    ## @param [String] tableName the name of the table to look into datamap
    ## @return [LineChart] this the current instance
    ##
    addTable: (@tableName) ->
        dm = DataMap.getDataMap()
        if !dm.types[@tableName] or !dm.data[@tableName]
            throw new Error "table with name #{@tableName} is not found"
        ##| converting the data to array for better access
        @tableRows = $.map dm.data[@tableName],(value) ->
            value
        this

    ## ----------------------------------------------------------------------------------------------------------------
    ## function to calculate the data to plot on chart
    ## the calculateCallback must return Object containing X and Y value
    ## for ex. {x: new Date(), y: 500}
    ##
    ## @param [Function] tableName the name of the table to look into datamap
    ## @return [LineChart] this the current instance
    ##
    calculate: (@calculateCallback) ->
        @calculatedData = []
        for row in @tableRows
            calculation = @calculateCallback(row,@calculatedData)
            # if !calculation.x or !calculation.y
            #     throw new Error "the returning object has not x and y value"
            ##| update new result set
            @calculatedData = calculation
        this

    ## ----------------------------------------------------------------------------------------------------------------
    ## function to set calculated data directly
    ##
    ## @param [Array] calculatedData array of object containing value for x and y
    ## @return [LineChart] this the current instance
    ##
    setCalculated: (@calculatedData) ->
        this

    ## ----------------------------------------------------------------------------------------------------------------
    ## function to filter the loaded rows
    ## if callback function returns false that row will be skipped
    ##
    ## @param [Function] filterCallback function to call on each row
    ## @return [LineChart] this the current instance
    ##
    filter: (@filterCallback) ->
        filteredResults = [];
        for row in @tableRows
            if @filterCallback row
                filteredResults.push row
        @tableRows = filteredResults
        this

    ## ----------------------------------------------------------------------------------------------------------------
    ## function to render the chart using the calculated data
    ##
    ##
    render: () ->
        if !@calculatedData.length
            throw new Error "calculated data not found! please perform calculation to provide chart data"
        ##| the type of chart is specified
        @withData @calculatedData, 'bar'
        super()
