## -------------------------------------------------------------------------------------------------------------
## class for DataTypeCollection
##
class DataTypeCollection

    ## -------------------------------------------------------------------------------------------------------------
    ## constructor
    ##
    ## @param [String] tableName to identify the DataTypeCollection inside dataMap
    ## @param [Object] cols the columns to include in the tables
    ##
    constructor: (@tableName) ->
        @col = {}

    ##|
    ##|  Returns the column if defined by
    getColumn: (source)=>
        if @col[source]?
            return @col[source]

        s = source.toLowerCase().replace("_", " ")
        for id, col of @col
            if col.getName().toLowerCase().replace("_", " ") == s then return col
            if col.getSource().toLowerCase().replace("_", " ") == s then return col

        return null

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
        @verifyOrderIsUnique();

        for source, col of @col
            output[source] = col.serialize()

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
    configureColumn: (col, skipDeduce = false) =>

        if !col? or !col.source?
            return

        if !@col[col.source]?
            @col[col.source] = new TableViewCol(@tableName)

        if !col.order? then col.order = Object.keys(@col).length

        @col[col.source].deserialize(col)

        if !skipDeduce? or skipDeduce == false
            @col[col.source].deduceInitialColumnType()

        return @col[col.source]

    ##|
    ##|  Verify that the sort order id for each column is unique
    verifyOrderIsUnique: ()=>

        seen = {}
        max  = 0

        ##|
        ##|  For any columns with a known order
        for source, col of @col
            order = col.getOrder()
            if order?
                if seen[order]?
                    col.changeColumn "order", null
                else
                    seen[order] = true

        ##|
        ##|  Assign all unassigned
        for source, col of @col
            if !col.getOrder()?
                max = max + 1 while seen[max]?
                col.changeColumn "order", max
                seen[max] = true

        names = Object.keys(@col).sort (a, b)=>
            return @col[a].getOrder() - @col[b].getOrder()

        max = 0
        for name in names
            @col[name].data.order = max++

        true


    ## -------------------------------------------------------------------------------------------------------------
    ## function to configure more than one columns
    ##
    ## @param [Array] columns columns to configure
    ## @return [Boolean]
    ##
    configureColumns: (columns, skipDeduce = false) =>

        # console.log "configureColumns:", columns

        for col in columns
            @configureColumn(col, skipDeduce)

        true
