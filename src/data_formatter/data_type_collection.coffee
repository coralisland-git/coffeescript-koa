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

    ##|
    ##|  Convert some javascript into a function for render() call
    ##|  It's suggested that the function be clean (renderFunctionToString) first.
    ##|
    @renderStringToFunction: (renderText)->
        try
            template = '''
                try {  // toStringWrapper
                XXCODEXX
                } catch (e) { console.log("Render error:",e); console.log("val=",val,"tableName=",tableName,"fieldName=",fieldName,"id=",id); return "Error"; }
            '''

            renderFunction = new Function("val", "tableName", "fieldName", "id", template.replace("XXCODEXX", renderText))
            # console.log "F=", renderFunction
            return renderFunction
        catch
            console.log "Error converting code to function:", renderText
            return null

    ##|
    ##|  Render is either a function or the string version of a function, cleanup the text
    ##|  and return something without the function prototype around it.
    ##|
    @renderFunctionToString: (render)->
        try
            # console.log "renderFunctionToString, initial:", render

            fun = render.toString().replace /^\s+/, ""
            if /^function/.test fun
                ##|
                ##|  This has a function wrapper around it already.   Remove it.
                fun = fun.replace /function[^\)]+\)/, ""
                fun = fun.replace /^[\s\r\n]/g, ""
                if fun.charAt(0) == '{'
                    fun = fun.replace /^\{/, ""
                    fun = fun.replace /[\}\s]+$/, ""

            if /toStringWrapper/.test fun
                fun = fun.replace /.*toStringWrapper/g, ""
                fun = fun.replace /.*\} catch .*Render error.*/, ""

            fun = fun.replace /^\s+/, ""
            fun = fun.replace /[\s\r\n]+$/g, ""
            # console.log "renderFunctionToString: return:", fun
            return fun

        catch e

            console.log "renderFunctionToString: Error creating function:", e
            return ""

    ##|
    ##|  Convert the data type collection back to values that can be saved to a database
    ##|
    toSave: ()=>

        output = {}

        for source, col of @col
            output[source] = $.extend true, {}, col
            delete output[source].formatter
            delete output[source].extraClassName
            delete output[source].dataFormatter

            if output[source].render? and typeof output[source].render == "function"
                ##|
                ##|  Convert function to string
                functionText = DataTypeCollection.renderFunctionToString(output[source].render)
                output[source]["render"] = functionText



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

        @col[c.source] = c
        @colList.push(c.source)

    ##|
    ##|  Verify that the sort order id for each column is unique
    verifyOrderIsUnique: ()=>

        seen = {}
        max  = 0

        ##|
        ##|  For any columns with a known order
        for source in @colList
            c = @col[source]
            if c.order? and typeof c.order == "number"
                if seen[c.order]?
                    c.order = null
                    console.log "Duplicate order for #{name}"
                else
                    seen[c.order] = true

        ##|
        ##|  Assign all unassigned
        for source in @colList
            c = @col[source]
            if !c.order?
                max = max + 1 while seen[max]?
                c.order = max++

        true


    ## -------------------------------------------------------------------------------------------------------------
    ## function to configure more than one columns
    ##
    ## @param [Array] columns columns to configure
    ## @return [Boolean]
    ##
    configureColumns: (columns) =>

        for col in columns
            @configureColumn(col)

        @verifyOrderIsUnique();
        true
