## -------------------------------------------------------------------------------------------------------------
## class TableViewCol to create and render single column for the table
## global functions required to use tables. the cell id is a counter
## used to create elements with a new unique ID
##
DataSetConfig = require 'edgecommondatasetconfig'
class TableViewColButton extends DataSetConfig.ColumnBase

    ## -------------------------------------------------------------------------------------------------------------
    ## constructor create new column object
    ##
    ## @param [String] name The name of the column
    ## @param [String] title The title to show in the header
    ##
    constructor : (@tableName, @id) ->
        @visible = true
        @width   = 60
        @sort    = 0
        @name    = @id

    render: (val)=>
        return @id

    getName: ()=>
        return @name

    getOrder: ()=>
        return 99

    ##|
    ##|  Returns the name of the source field in the datamap
    getSource : ()=>
        if @source? then return @source
        return @id

    ##|
    ##|  Returns the name of the foramtter for this field
    getFormatterName: ()=>
        return "table_button"

    getAlign: ()=>
        return "center"

    getClickable: ()=>
        return true

    ##|
    ##|  returns true if the field is editable
    getEditable: ()=>
        return false

    getWidth: ()=>
        return @width

    ## -------------------------------------------------------------------------------------------------------------
    ## RenderHeader function to render the header for the column
    ##
    ## @param [String] extraClassName extra class name that will be included in the th
    ## @return [String] html the html for the th
    ##
    RenderHeader: (parent, location) =>
        parent.html @getName()
        parent.addClass "text-center"
        parent.addClass "tableHeaderField"
        return parent

    RenderHeaderHorizontal: (parent, location) =>
        parent.html @tableName
        parent.addClass "text-center"
        parent.addClass "tableHeaderFieldHoriz"
        return parent

    UpdateSortIcon: (newSort) =>
        true
