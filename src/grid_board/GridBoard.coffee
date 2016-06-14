class GridBoard

    constructor: (holderName) ->

        @options =

            gridPadding : 10

        ##|
        ##|  Shadow the element to hold the grid
        @elHolder = $("#" + holderName.replace("#", ""))
        @resize()

        ##|
        ##|  Add a global resize handler that will only
        ##|  internally resize after movement has stopped for a short amount of time.
        ##|
        $(window).resize (e)=>
            if @resizeTimer?
                clearTimeout @resizeTimer

            @resizeTimer = setTimeout ()=>
                @resize()
            , 250

            true

    resize: ()=>

        if @resizeTimer?
            clearTimeout @resizeTimer

        ##|
        ##|  The holder element would have already been grown so we need the
        ##|  parent element to know the actual size.
        ##|
        totalWidth  = @elHolder.parent().width()
        totalHeight = @elHolder.parent().height()

        console.log "Available space = #{totalWidth} x #{totalHeight}"

        gridItems = @elHolder.find(".gridItem")
        rows = {}
        for el in gridItems
            dw  = parseInt $(el).attr("data-width")
            dh  = parseInt $(el).attr("data-height")
            row = parseInt $(el).attr("data-row")
            if !rows[row]?
                rows[row] =
                    cols: []
                    width: 0

            rows[row].width += dw
            rows[row].cols.push
                el      : $(el).detach()
                width   : dw
                hheight : dh

        ##|
        ##|  loop through all rows, find the max width
        maxWidth = 0
        maxRow = 0
        for num, row of rows
            console.log "ROW=", row
            if row.width > maxWidth then maxWidth = row.width
            if num > maxRow then maxRow = num

        ##|
        ##|  Calculate the maximum space available for each column
        spaceX = Math.floor(totalWidth / maxWidth)

        ##|
        ##|
        console.log "maxRow=#{maxRow} maxWidth=#{maxWidth}, spaceX=#{spaceX}"

        @elHolder.html ""
        isFirstRow = true
        for num in [0..maxRow]
            if !rows[num]? then continue

            row = rows[num]
            console.log "Adding #{num}: ", row

            elRow = $ "<div class='gridRow' />"
            @elHolder.append elRow

            isFirstCol = true
            colNum = 0
            for col in row.cols
                console.log "Adding col:", col

                cellWidth = (col.width * spaceX)

                ##|
                ##|  Add the cell that holds this part of the grid
                ##|  add padding as needed depending on the location.
                ##|
                cell = $ "<div class='gridCell' />"
                cell.css "padding", 0
                if !isFirstRow then cell.css "paddingTop", @options.gridPadding

                if colNum > 0
                    cell.css "paddingLeft", @options.gridPadding
                    cellWidth -= @options.gridPadding

                elRow.append cell
                col.el.css "width", cellWidth

                cell.append col.el
                # cell.css "width", col.width * spaceX

                isFirstRow = false
                colNum++

                cell.on "resize", (e)=>
                    console.log "Cell resize"
                    console.log "e=", e








