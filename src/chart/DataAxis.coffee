class DataAxis

    constructor: (options)->

        @data = {}
            # title: "Title not set"

        if options?
            $.extend @data, options

        @setLabelFontSize 16
        @setLabelFontAngle 0

    ##|
    ##|  Set the axis to format for money
    setFormatMoney: ()=>

        # @setPrefix '$ '

        @data.labelFormatter = (e)=>
            num = e.value
            if !num? then return ""
            if typeof num != "number" then return num

            if num < 10000
                return numeral(num).format('#,###')

            if num < 1000000
                return numeral(num / 1000).format('#,###') + " k"

            return numeral(num / 1000000).format('#,###.[###]') + " m"

    ##|
    ##|  Set a new title or unset the dummy title by sending null
    setTitle: (title)=>
        if !title?
            delete @data.title
        else
            @data.title = title

    setRange: (minvalue, maxvalue)=>
        @data.minimum = minvalue
        @data.maximum = maxvalue

    setFormatString: (str)=>
        @data.valueFormatString = str

    setPrefix: (str)=>
        @data.prefix = str

    setLabelFontSize: (newSize)=>
        @data.labelFontFamily = "San Francisco Display,Arial,sans-serif"
        @data.labelFontSize   = newSize

    setLabelFontAngle: (newAngle)=>
        @data.labelAngle = newAngle

    setLabelFontColor: (newColor)=>
        @data.labelFontColor = newColor

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

    addOptions: (options) =>
        for key, value of options
            @data[key] = value
        return options