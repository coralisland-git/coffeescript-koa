## -------------------------------------------------------------------------------------------------------------
## class TableViewDetailed widget to display the table in vertical manner it mostly used to display single row
## including all data for the single row
##
## @extends [TableView]
##
class TableViewDetailed extends TableView

    # @property [Integer] leftWidth
    leftWidth : 100

    # @property [Integer] dataWidth - the smallest width for a column
    dataWidth : 120

    constructor: (@elTableHolder, @showCheckboxes) ->
        super(@elTableHolder, @showCheckboxes)
        @showFilters      = false
        @fixedHeader      = true
        @showGroupPadding = false
        @showResize       = false

    getTableTotalRows: ()=>
        if !@colByNum? then return 0
        count = Object.keys(@colByNum).length

    getTableTotalCols: ()=>
        return @totalAvailableRows + 1

    ##|  Number of visible columns
    getTableVisibleCols: ()=>

        if @cachedTotalVisibleCols? then return @cachedTotalVisibleCols

        visColCount = 0
        x           = 0
        colNum      = @offsetShowingLeft
        maxWidth    = @getTableVisibleWidth()
        totalCols   = @getTableTotalCols()

        while x < maxWidth and colNum < totalCols

            while (colNum < totalCols) and @shouldSkipCol(location)
                colNum++

            if colNum >= totalCols
                break

            location =
                colNum: colNum
                visibleCol: visColCount

            x = x + @getColWidth location
            visColCount++
            colNum++

        @cachedTotalVisibleCols = visColCount
        return visColCount

    getColWidth: (location)=>
        if @showHeaders and location.visibleCol == 0 then return @leftWidth
        if @totalAvailableRows == location.visibleCol
            return @getTableVisibleWidth() - @leftWidth - (@dataWidth * (@totalAvailableRows-1))
        return @dataWidth

    getCellStriped: (location)=>
        if @showHeaders and location.visibleCol == 0 then return false
        return location.visibleRow % 2 == 1

    ##|
    ##|  Return true if a cell is editable
    ##|
    getCellEditable: (location)=>
        if !@colByNum[location.rowNum]? then return null
        return @colByNum[location.rowNum].getEditable()
    ##|
    ##|  Return right/left/center - left is assumed by default
    getCellAlign: (location)=>
        if !@colByNum[location.rowNum]? then return null
        if location.visibleCol == 0 then return 'right'
        return 'left'
        # return @colByNum[location.rowNum].getAlign()

    getCellTablename: (location)=>
        if !@colByNum[location.rowNum]? then return null
        return @colByNum[location.rowNum].tableName

    getCellSource: (location)=>
        if !@colByNum[location.rowNum]? then return null
        return @colByNum[location.rowNum].getSource()

    getCellRecordID: (location)=>
        if !@rowDataRaw[location.colNum]? then return 0
        return @rowDataRaw[location.colNum].id

    getCellFormatterName: (location)=>
        if !@colByNum[location.rowNum]? then return null
        return @colByNum[location.rowNum].getFormatterName()

    shouldSkipRow: (rowNum)=>
        if !@colByNum[location.rowNum]? then return true
        return false

    shouldSkipCol: (colNum)=>
        if !@rowDataRaw[location.colNum]? then return false
        if @rowDataRaw[location.colNum].visible? and @rowDataRaw[location.colNum].visible == false then return true
        return false

    isHeaderCell: (location)=>
        if @showHeaders and location.visibleCol == 0 then return true
        return false

    shouldAdvanceCol: (location)=>
        if @showHeaders and location.visibleCol == 1 then return false
        return true

    ##|
    ##|  Returns a state record for the current row
    ##|  data - Cells of data
    ##|  locked - Cells of header or locked content
    ##|  group - Starting a new group
    ##|  skip - Skip this row
    ##|  invalid - Invalid row
    ##|
    getRowType: (location)=>
        if !@colByNum[location.rowNum]?
            return "invalid'"
            # console.log "returning invalid getRowType: #{location.rowNum}"

        if !@colByNum[location.rowNum]? then return "invalid"
        return "data"

    setHeaderField: (location)=>
        location.cell.html ""
        if !@colByNum[location.rowNum]? then return false
        @colByNum[location.rowNum].RenderHeaderHorizontal location.cell, location
        location.cell.setDataPath "/#{location.tableName}/Header/#{location.sourceName}"

    getCellSelected: (location)=>
        if @rowDataRaw[location.colNum]? and @rowDataRaw[location.colNum].row_selected
            return true

        return false

    getCellType: (location)=>
        if @isHeaderCell(location) then return "locked"
        if not location.colNum? or !@rowDataRaw[location.colNum]?
            console.log "detail return invalid 1", location.colNum
            return "invalid"
        if !@rowDataRaw[location.colNum]?
            console.log "detail return invalid 2"
            return "invalid"
        if @rowDataRaw[location.colNum].type? then return @rowDataRaw[location.colNum].type
        return "data"

    setDataField: (location)=>

        col = @colByNum[location.rowNum]
        if col.getSource() == "row_selected"
            if @getRowSelected(@rowDataRaw[location.colNum].id)
                location.cell.html @imgChecked
            else
                location.cell.html @imgNotChecked

        else if col.render?
            location.cell.html col.render(@rowDataRaw[location.colNum][col.getSource()], @rowDataRaw[location.colNum])
        else
            displayValue = DataMap.getDataFieldFormatted col.tableName, @rowDataRaw[location.colNum].id, col.getSource()
            location.cell.html displayValue

        true