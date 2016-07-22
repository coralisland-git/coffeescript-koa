## -------------------------------------------------------------------------------------------------------------
## class TableViewCol to create and render single column for the table
## global functions required to use tables. the cell id is a counter
## used to create elements with a new unique ID
##
class TableViewColButton

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

    render: (val)=>
        return @id

    ##|
    ##|  Returns the name of the source field in the datamap
    getSource : ()=>
        return @tableName + "_" + @id

    ##|
    ##|  Returns the name of the foramtter for this field
    getFormatterName: ()=>
        return "table_button"

    getAlign: ()=>
        return "center"

    ##|
    ##|  returns true if the field is editable
    getEditable: ()=>
        return false

    calculateWidth: ()=>

        if !@visible? then return 0
        return @width

    ## -------------------------------------------------------------------------------------------------------------
    ## RenderHeader function to render the header for the column
    ##
    ## @param [String] extraClassName extra class name that will be included in the th
    ## @return [String] html the html for the th
    ##
    RenderHeader: (extraClassName, parent) =>

        if @visible == false then return

        tag = parent.addDiv "tableHeaderField"

        tag.setDataPath "/#{@tableName}/Header/Action"
        tag.html "&nbsp;"

        return tag

    UpdateSortIcon: (newSort) =>
        true
