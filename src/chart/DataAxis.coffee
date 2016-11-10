class DataAxis

    constructor: (options)->

        @data =
            title: "Title not set"

        if options?
            $.extend @data, options

    setTitle: (title)=>
        @data.title = title

    setRange: (minvalue, maxvalue)=>
        @data.minimum = minvalue
        @data.maximum = maxvalue

    setFormatString: (str)=>
        @data.valueFormatString = str

    setPrefix: (str)=>
        @data.prefix = str

    setFormatMoney: ()=>
        @setFormatString '#,##0.##'
        @setPrefix '$ '


    addStripLine: (startValue, endValue, options)=>

        if !@data.stripLines
            @data.stripLines = []

        stripLine =
            startValue : startValue
            endValue   : endValue
            color      : "#2FD971"
            showOnTop  : true
            labelAlign : "near"

        if endValue == startValue
            stripLine.value = startValue
            delete stripLine.endValue
            delete stripLine.startValue

        $.extend stripLine, options
        @data.stripLines.push stripLine
        return stripLine