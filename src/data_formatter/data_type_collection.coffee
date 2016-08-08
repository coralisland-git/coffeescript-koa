## -------------------------------------------------------------------------------------------------------------
## A list of data types that go together such as columns in a table
## or database columns.   The configName part of the constructor is used
## to save or load the configuration if needed
##
class DataType

    # @property [String] source data source to copy from
    source        : ''

    # @property [Boolean] visible used for tables
    visible       : false

    # @property [Boolean] editable inline edit for display
    editable      : false

    # @property [Boolean] hideable can be hidden
    hideable      : true

    # @property [Boolean] required used to create a new record
    required      : false

    # @property [String] type data type text
    type          : ''

    # @property [String] tooltip tooltip text
    tooltip       : ''

    # @property [Function|null] formatter additional formatter to use for getting formatted value
    formatter     : null

    # @property [null|Function] displayFormat formatter to display the data on screen
    displayFormat : null

    ## -------------------------------------------------------------------------------------------------------------
    ## constructor
    ##
    constructor: () ->


## -------------------------------------------------------------------------------------------------------------
## class for DataTypeCollection
##
class DataTypeCollection

    ## -------------------------------------------------------------------------------------------------------------
    ## constructor
    ##
    ## @param [String] configName to identify the DataTypeCollection inside dataMap
    ## @param [Object] cols the columns to include in the tables
    ##
    constructor: (@configName, cols) ->

        @col = {}
        @colList = []
        if cols? then @configureColumns cols

    contains: (source)=>
        if @col[source]? then return true
        return false

    toSave :()=>
        output = {}
        for source, col of @col
            output[source] = $.extend true, {}, col
            delete output[source].formatter
            delete output[source].extraClassName

        return output

    ## -------------------------------------------------------------------------------------------------------------
    ## Given an array of column configuration structures, create new
    ## columns automatically based on the configuration.
    ##
    ## @example
    ##      dc.configureColumn
    ##            name: 'Create Date'
    ##            source: 'create_date'
    ##            visible: true
    ##            hideable: true
    ##            editable: true
    ##            type: 'datetime'
    ##            required: false
    ##
    configureColumn: (col) =>

        c = new DataType()

        for name, value of col
            c[name] = value

        ##|
        ##|  Allocate the data formatter
        c.formatter = globalDataFormatter.getFormatter col.type
        c.extraClassName = "col_" + @configName + "_" + col.source

        ##|
        ##| Optional render function on the column
        if typeof col.render == "function"
            c.displayFormat = col.render

        @col[c.source] = c
        @colList.push(c.source)


    ## -------------------------------------------------------------------------------------------------------------
    ## function to configure more than one columns
    ##
    ## @param [Array] columns columns to configure
    ## @return [Boolean]
    ##
    configureColumns: (columns) =>

        for col in columns
            @configureColumn(col)

        ##|
        ##|  See if there is any CSS to inject

        css = ""
        for i, col of @col

            str = ""
            if col.width? and col.width
                str += "width : #{col.width}px; "
            if col.align? and col.align
                str += "text-align : " + col.align

            if str and str.length > 0
                css += "." + col.extraClassName + " {"
                css += str
                css += "}\n"

        if css
            $("head").append "<style type='text/css'>\n" + css + "\n</style>"

        # $('head').append('<style type="text/css">body{font:normal 14pt Ar

        true
