##|
##|  A list of data types that go together such as columns in a table
##|  or database columns.   The configName part of the constructor is used
##|  to save or load the configuration if needed
##|

root = exports ? this

root.DataType = class DataType

    source        : ''       ##| Data source to copy from
    visible       : false    ##| Visible (Used for tables)
    editable      : false    ##| Editable (Inline edit for display)
    hideable      : true     ##| Can be hidden
    required      : false    ##| Used to create a new record
    type          : ''       ##| Data type text
    tooltip       : ''       ##| Tooltip text
    formatter     : null
    displayFormat : null

    constructor: () ->

root.DataTypeCollection = class DataTypeCollection

    colList : []
    col     : {}

    constructor: (configName, cols) ->

        if cols? then @configureColumns cols

    ##|
    ##|  Given an array of column configuration structures, create new
    ##|  columns automatically based on the configuration.
    ##|  Example:
    ##|
    ##|  name       : 'Create Date'
    ##|  source     : 'create_date'
    ##|  visible    : true
    ##|  hideable   : true
    ##|  editable   : true
    ##|  type       : 'datetime'
    ##|  required   : false
    ##|
    configureColumn: (col) =>

        c = new DataType()

        for name, value of col
            c[name] = value

        ##|
        ##|  Allocate the data formatter
        c.formatter = globalDataFormatter.getFormatter col.type

        ##|
        ##| Optional render function on the column
        if typeof col.render == "function"
            c.displayFormat = col.render

        @col[c.source] = c
        @colList.push(c.source)


    ##|
    ##|  Same as configureColumn but allows and array to be passed in
    ##|
    configureColumns: (columns) =>

        for col in columns
            @configureColumn(col)





