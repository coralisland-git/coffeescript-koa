##|
##|  To help with automated testing
globalChartCounter = 0

class ViewDataChart extends View

    getDependencyList: ()=>
        return ["/vendor/canvasjs.min.js"]

    onSetupButtons: () =>
        console.log "ViewDataChart onSetupButtons holder=", @elHolder

    onShowScreen: ()=>
        console.log "ViewDataChart onShowScreen holder=", @elHolder
        @chartOptions = {}
        @axisX  = new DataAxis()
        @axisY  = new DataAxis()
        @chartOptions.backgroundColor = "#E6F8F2"

    addAxisY: ()=>

        if !Array.isArray(@axisY)
            tmp = [ @axisY, new DataAxis() ]
            @axisY = tmp
        else
            @axisY.push new DataAxis()

        return @axisY[@axisY.length-1]

    setTitle: (title)=>
        @chartOptions.title =
            text            : title
            fontSize        : 18
            horizontalAlign : "right"
        return @chartOptions.title

    ##|
    ##|  Add a DataSeries object
    setData: (dataSeries)=>
        if !@chartOptions.data?
            @chartOptions.data = []

        if dataSeries.data.type != "doughnut"
            dataSeries.setIndexThemeColor(@chartOptions.data.length)

        @chartOptions.data.push dataSeries.getData()
        return @chartOptions

    onResize : (w, h)=>
        return


    setSize: (w, h)=>
        @elHolder.width(w)
        @elHolder.height(h)
        @elHolder.find("#chart#{@gid}").width(w).height(h);

        if @chart?
            return @onRender()

        true

    onRender: ()=>
        @chart.render()
        true

    show: (name)=>
        if @chart? then return @onRender()

        @chartOptions.axisX = @axisX.data

        if Array.isArray(@axisY)
            @chartOptions.axisY = []
            for a in @axisY
                @chartOptions.axisY.push a.data
        else
            @chartOptions.axisY = @axisY.data

        @gid = globalChartCounter++
        if name? then @gid = name
        @elHolder.find(".chartHolder").html("<div id='chart#{@gid}'/>")
        # console.log "Setting chart to ", @elHolder.find(".chartHolder"), " opt=", @chartOptions
        @chart = new CanvasJS.Chart("chart" + @gid, @chartOptions)
        @chart.render()

        true
