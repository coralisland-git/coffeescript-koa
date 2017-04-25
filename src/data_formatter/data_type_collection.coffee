## -------------------------------------------------------------------------------------------------------------
## class for DataTypeCollection
##
DateSetConfig = require 'edgecommondatasetconfig'

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
            @col[col.source] = new DataSetConfig.Column(@tableName)

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
