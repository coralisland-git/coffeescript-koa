##|
##|  A list of data types that go together such as columns in a table
##|  or database columns.   The configName part of the constructor is used
##|  to save or load the configuration if needed
##|

class DataTypeCollection

    constructor: (configName) ->

    ##|
    ##|  Given an array of column configuration structures, create new
    ##|  columns automatically based on the configuration.
    ##|  Example:
    ## name       : 'Create Date'
    ## source     : 'create_date'
    ## visible    : true
    ## hideable   : true
    ## editable   : true
    ## type       : 'datetime'
    ## required   : false
    configureColumns: (columns, @tableCacheName) =>

        for col in columns

            c = new TableViewCol col.source, col.name

            ##|
            ##|  Check for an override in the config
            customValue = user.tableConfigGetColumnVisible(@tableCacheName, c.name)
            if customValue != null
                col.visible = customValue

            ##|
            ##|  Tooltip, if specified, is shown when you hover over the column
            c.tooltip  = col.tooltip
            c.visible  = col.visible
            c.editable = col.editable
            c.options  = col.options

            formatter = c.initFormat col.type, col.options

            if col.limit and col.limit > 0 and col.limit < 30
                if formatter.width == null
                    formatter.setWidth "#{col.limit * 8}px"

            ##|
            ##| Optional render function on the column
            if typeof col.render == "function"
                formatter.displayFormat = col.render

            ##|
            ##| Optional width setting
            if typeof col.width == "number"
                formatter.setWidth(col.width + "px");

            @colList.push(c)