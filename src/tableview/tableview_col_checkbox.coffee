## -------------------------------------------------------------------------------------------------------------
## class TableViewCol to create and render single column for the table
## global functions required to use tables. the cell id is a counter
## used to create elements with a new unique ID
##
DataSetConfig = require 'edgecommondatasetconfig'
class TableViewColCheckbox extends DataSetConfig.ColumnBase

    ## -------------------------------------------------------------------------------------------------------------
    ## constructor create new column object
    ##
    ## @param [String] name The name of the column
    ## @param [String] title The title to show in the header
    ##
    constructor : (@tableName) ->

        @visible = true
        @width   = 32
        @sort    = 0

    getName: ()=>
        return "row_selected"

    ##|
    ##|  Returns the name of the source field in the datamap
    getSource : ()=>
        return "row_selected"

    ##|
    ##|  Returns the name of the foramtter for this field
    getFormatterName: ()=>
        return "boolean"

    getAlign: ()=>
        return "center"

    getOrder: ()=>
        return -99

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

        if @visible == false then return
        parent.addClass "checkable"
        parent.addClass "tableHeaderField"
        parent.html ""
        parent

    RenderHeaderHorizontal: (parent, location) =>

        if @visible == false then return

        parent.addClass "checkable"
        parent.addClass "tableHeaderFieldHoriz"
        parent.html "Select Row"
        parent.el.css
            "text-align"    : "right"
            "padding-right" : 8
            "border-right"  : "1px solid #CCCCCC"
            "background"    : "linear-gradient(to right, #fff, #f2f2f2);"

        return parent

    UpdateSortIcon: (newSort) =>
        true
