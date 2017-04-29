## -------------------------------------------------------------------------------------------------------------
## class TableViewCol to create and render single column for the table
## global functions required to use tables. the cell id is a counter
## used to create elements with a new unique ID
##

reDate1   = /^[0-9][0-9][0-9][0-9].[0-9][0-9].[0-9][0-9]T00.00.00.000Z/
reDate2   = /^[0-9][0-9][0-9][0-9].[0-9][0-9].[0-9][0-9]T[0-9][0-9].[0-9][0-9].[0-9][0-9].[0-9][0-9][0-9]Z/
reNumber  = /^[\-1-9][0-9]{1,10}$/
reDecimal = /^[\-1-9\.][0-9\.]{1,11}\.[0-9]+$/
DataSetConfig   = require 'edgecommondatasetconfig'
dataFormatter   = new DataSetConfig.DataFormatter()

class TableViewColBase

    getName: ()->
        return "No name"

    getSource: ()->
        return ""

    getOrder: ()->
        return 999

    getOptions: ()->
        return null

    getClickable: ()->
        return false

    getEditable: ()->
        return false

    getAlign: ()->
        return null

    getWidth: ()=>
        return 0;

    RenderHeader: (parent, location) =>
        parent.html "No RenderHeader"

    RenderHeaderHorizontal: (parent, location) =>
        parent.html "No RenderHeaderHorizontal"

    UpdateSortIcon: (newSort)->
        return null

    getVisible: ()->
        return true

    getType: ()=>
        return "text"

    getFormatter: ()=>
        if @formatter then return @formatter
        @formatter = dataFormatter.getFormatter @getType()

    getFormatterName: ()=>
        f = @getFormatter()
        if f? then return f.name
        return null

    onFocus: (e, col, data) =>
        f = @getFormatter()
        if f? and f.onFocus? then f.onFocus e, col, data
        true

    getRequired: ()=>
        return false

    getAlwaysHidden: ()=>
        return false

    getSystemColumn: ()=>
        return false

    getAutoSize: ()=>
        return false

    getIsCalculation: ()=>
        return false

    ##|
    ##|  Return html to display
    ##|  @param value [mixed] Whatever the current value is in database format
    ##|  @param value [mixed] The key value on the row for this record if any
    ##|  @param value [object] The row object if any
    renderValue: (value, keyValue, row)=>
        return value

    ##|
    ##|  Update configuration of the column
    ##|  The varName / value should be the same as defined
    ##|  in the "serialize" function but we allow one update
    ##|  function we can adjust the related fields in the subclasses.
    changeColumn: (varName, value)=>
        return true

    getRenderFunction: ()=>
        return null

    renderTooltip: (row, value, tooltipWindow)=>
        return false

    ##|
    ##|  Given some new data, see if we need to automatically change
    ##|  the data type on this column.
    deduceColumnType: (newData)=>
        return null

    ##|
    ##|  Called once when the column is created to see if the
    ##|  class wants to update the information on the column type
    deduceInitialColumnType: ()=>
        return null

    serialize: ()=>

        obj           = {}
        obj.name      = @getName()
        obj.type      = @getType()
        obj.width     = @getWidth()
        obj.options   = @getOptions()
        obj.editable  = @getEditable()
        obj.visible   = @getVisible()
        obj.clickable = @getClickable()
        obj.align     = @getAlign()
        obj.source    = @getSource()
        obj.required  = @getRequired()
        obj.hideable  = @getAlwaysHidden()
        obj.system    = @getSystemColumn()
        obj.autosize  = @getAutoSize()
        obj.order     = @getOrder()
        obj.render    = @getRenderFunction()
        obj.calculate = @getIsCalculation()

        # console.log "SERIALIZE:", @data

        if @data.render? and typeof @data.render == "string" and @data.render.charAt(0) == '='
            obj.render = @data.render

        return obj

    deserialize: (obj)=>

        for varName, value of obj
            @changeColumn varName, value

        true
