##| Chart Widget to add chart using canvasJS
##|
##| example usage:
##| c = new Chart("renderItemId", "title of the chart")
##| c.withData()

class Chart

    # @property [Array] tableRows total tablerows
    tableRows: []

    # @property [Array] calculated data to render inside chart
    calculatedData: []

    # @property [Boolean|static] isCanvasLoaded weather canvas js is loaded or not
    @isCanvasLoaded : false

    # @property [String|static] canvasJSPath the path from where canvas js will be loaded
    @canvasJSPath: "/vendor/canvasjs.min.js"

    # @property [Object] _options options to apply to canvas js chart
    _options:
        theme: "theme2",
        title:
            text: ""
        animationEnabled: true
        creditText: "protovate.com"
        data: []

    # @property [Integer] height the height will be set to parent element
    height: 300

    # @property [Object] _chartInstance the internal chart instance
    _chartInstance = null

    ## ----------------------------------------------------------------------------------------------------------------
    ## constructor to initialize the chart
    ##
    ## @return this [CodeEditor] returns instance
    ##
    constructor: (@elHolderId, title = "Another new Chart")->
        ##| loading canvas js if not already loaded
        if !Chart.isCanvasAvailable()
            Chart.loadJs()
        if ! $("##{@elHolderId}").length
            throw new Error "the element with id #{@elHolderId} is not found";
        $ "##{@elHolderId}"
            .height @height
        @_options.title.text = title

    ## ----------------------------------------------------------------------------------------------------------------
    ## function to set info about xAxis
    ##
    ## @param [Object] xAxisObject a posible properties that can be assigned to x Axis
    ## @return this [CodeEditor] returns instance
    ##
    xAxis: (xAxisObject) ->
        @_options.axisX = xAxisObject
        this

    ## ----------------------------------------------------------------------------------------------------------------
    ## function to set info about yAxis
    ##
    ## @param [Object] yAxisObject a posible properties that can be assigned to y Axis
    ## @return this [CodeEditor] returns instance
    ##
    yAxis: (yAxisObject) ->
        @_options.axisY = yAxisObject
        this

    ## ----------------------------------------------------------------------------------------------------------------
    ## function to set height
    ##
    ## @param [Integer] height the new height to apply to the parent
    ## @return this [Chart] returns instance
    ##
    setHeight: (@height) ->
        $ "##{@elHolderId}"
            .height @height
        this

    ## ----------------------------------------------------------------------------------------------------------------
    ## function to set data in the chart
    ##
    ## @param [String] type any valid canvas js chart type
    ## @param [Array] data the datapoints array to render inside chart
    ## @param [Object] additonalOptions options to pass in data series
    ## @return this [Chart] returns instance
    ##
    withData: (data, type = 'line', addtionalOptions = {}) ->
        dataObject =
            type: type
            dataPoints: data
        $.extend dataObject,addtionalOptions
        @_options.data.push(dataObject)
        this

    ## ----------------------------------------------------------------------------------------------------------------
    ## render placeholder
    ##
    ## @return this [Chart] returns instance
    ##
    render: ->

        @realRender()

    ## ----------------------------------------------------------------------------------------------------------------
    ## render function to create chart instance
    ##
    ## @return this [Chart] returns instance
    ##
    realRender: ()=>

        @_chartInstance = new CanvasJS.Chart @elHolderId,
            @_options

        console.log @_chartInstance, @_options
        @_chartInstance.render()

    ## ----------------------------------------------------------------------------------------------------------------
    ## function to get the canvas instance in which chart is initialized
    ##
    ## @return this [Object] CanvasJS object
    ##
    getCanvasInstance: ->
        @_chartInstance

    ## ----------------------------------------------------------------------------------------------------------------
    ## function to add options for chart
    ##
    ## @return this [Chart] returns instance
    ##
    setOptions: (options) =>
        @_options = $.extend {}, @_options, options
        this

    ## ----------------------------------------------------------------------------------------------------------------
    ## function to check if canvas js is available in the current document
    ## this function is static so use it with class instead of instance
    ##
    ## @return [Boolean] isCanvasAvailable if canvas js is availabe to use or not
    ##
    @isCanvasAvailable: ->
        if Chart.isCanvasLoaded
            return true
        else
            ##| check if canvas js loaded outside of plugin
            if window.CanvasJS && typeof window.CanvasJS != undefined
                Chart.isCanvasAvailable = true
                return true
            return false

    ## ----------------------------------------------------------------------------------------------------------------
    ## function to load the canvas js async if not available
    ## this function is static so use it with class instead of instance
    ##
    @loadJs: ->
        if !Chart.isCanvasAvailable()
            p = new Promise (resolve,reject) ->
                    script = $ "<script />",
                        type: "text/javascript"
                    .appendTo $("head")
                    script.on 'load', () ->
                        console.log "canvasjs loaded"
                        Chart.isCanvasLoaded = true
                        resolve()
                    script.on 'error', () ->
                        conosle.log "error loading canvas js"
                        reject()
                    script.attr 'src', Chart.canvasJSPath
            return p
        return Promise.resolve()

    ## ----------------------------------------------------------------------------------------------------------------
    ## function to add the table data into line chart
    ##
    ## @param [String] tableName the name of the table to look into datamap
    ## @return [LineChart] this the current instance
    ##
    addTable: (@tableName) ->

        DataMap.addPendingPromise ()=>

            dm = DataMap.getDataMap()
            if !dm.types[@tableName]
                throw new Error "table with name #{@tableName} is not found"

            @tableRows = DataMap.getValuesFromTable @tableName
            console.log "ROWS=", @tableRows
            return @tableRows

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

        console.log "Clearing pending first..."
        DataMap.clearPendingPromises()

        console.log "HERE Calculate:", @tableRows
        @calculatedData = []
        for row in @tableRows
            calculation = @calculateCallback(row, @calculatedData)
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
