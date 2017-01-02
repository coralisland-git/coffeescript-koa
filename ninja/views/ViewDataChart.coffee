##|
##|  To help with automated testing
globalChartCounter = 0

class ViewDataChart extends View

    getDependencyList: ()=>
        return ["http://canvasjs.com/assets/script/canvasjs.min.js"]

    onSetupButtons: () =>
        console.log "ViewDataChart onSetupButtons holder=", @elHolder

    onShowScreen: ()=>
        console.log "ViewDataChart onShowScreen holder=", @elHolder
        @chartOptions = {}
        @axisX = new DataAxis()
        @axisY = new DataAxis()
        @chartOptions.backgroundColor = "#E6F8F2"

    setTitle: (title)=>
        @chartOptions.title =
            text: title
            fontSize: 18
            horizontalAlign: "right"
        return @chartOptions.title

    ##|
    ##|  Add a DataSeries object
    setData: (dataSeries)=>
        if !@chartOptions.data?
            @chartOptions.data = []

        @chartOptions.data.push dataSeries.getData()
        return @chartOptions

    onResize : (w, h)=>
        height    = $(window).height()
        if !@elHolder? then return

        if w? and h?
            @elHolder.width(w)
            @elHolder.height(h)
            @elHolder.find("#chart#{@gid}").width(w).height(h);
        else
            pos       = @elHolder.position()
            offset    = @elHolder.offset()
            newHeight = height - pos.top
            newHeight = Math.floor(newHeight)
            @elHolder.height(newHeight)
            @elHolder.width("100%")
            @elHolder.find("#chart#{@gid}").width("100%").height(newHeight);

        if @chart?
            return @onRender()

        true

    onRender: ()=>
        @chart.render()
        true

    show: (name)=>
        if @chart? then return onRender()

        @chartOptions.axisX = @axisX.data
        @chartOptions.axisY = @axisY.data

        @gid = globalChartCounter++
        if name? then @gid = name
        @elHolder.find(".chartHolder").html("<div id='chart#{@gid}'/>")
        # console.log "Setting chart to ", @elHolder.find(".chartHolder"), " opt=", @chartOptions
        @chart = new CanvasJS.Chart("chart" + @gid, @chartOptions)
        @chart.render()

        true
