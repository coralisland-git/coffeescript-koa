## -------------------------------------------------------------------------------------------------------------
## class ModalMessageBox to show modal as message box


##
## @extends [ModalDialog]
##
class ModalSortItems extends ModalDialog

    # @property [String] content the content of the modal
    content:      "Sort Columns"

    # @property [String] title the title of the modal
    title:        "Customize Columns"

    # @property [String] ok text of the button1
    ok:           "Close"

    # @property [String] close text of the button2
    close:        ""

    # @property [Boolean] showFooter to show footer or not
    showFooter:   true

    # @property [Boolean] showOnCreate
    showOnCreate: false

    imgChecked     : "<img src='/images/checkbox.png' width='16' height='16' alt='Selected' />"

    # @property [String] imgNotChecked html to be used when checkbox is not checked
    imgNotChecked  : "<img src='/images/checkbox_no.png' width='16' height='16' alt='Selected' />"

    updateColumnText: ()=>

        for col in @columns
            if col.getAlwaysHidden() then continue

            col.tagName.html col.getName()
            col.tagOrderText.html col.getOrder()+1
            if col.getVisible()
                col.tagCheck.html @imgChecked
                col.tag.removeClass "notVisible"
            else
                col.tagCheck.html @imgNotChecked
                col.tag.addClass "notVisible"

            col.tag.setClass "calculation", col.getIsCalculation()

        true

    onClickVisible: (e)=>
        for col in @columns
            if col.getAlwaysHidden() then continue
            if col.getSource() != e.path then continue
            DataMap.changeColumnAttribute @tableName, e.path, "visible", (col.getVisible() == false)
            @updateColumnText()

    ## -------------------------------------------------------------------------------------------------------------
    ## constructor
    ##
    ## @param [String] message the message to show in the modal as message
    ##
    constructor: (@tableName) ->

        ##|
        ##|  List is an array
        ##|  with each element has name, order, active
        ##|

        super()

        GlobalClassTools.addEventManager(this)

        @content = '''
            <div id='tableColumnSortingList' class='tableColumnSortingList'>
            </div>
        '''
        @columnSortingListWrapper = @contentWrapper.addDiv "tableColumnSortingList", "tableColumnSortingList"
        @show()
        @sortItemsList = @columnSortingListWrapper.add "ul", "sortedItemsList", "sortedItemsList"
        #$("#tableColumnSortingList").append(@sortItemsList.el)

        ##|
        ##|  Get the columns
        @columns = DataMap.getColumnsFromTable(@tableName)
        @columns = @columns.sort (a, b)->
            return a.getOrder() - b.getOrder()

        for col in @columns
            if col.getAlwaysHidden() then continue

            col.tag          = @sortItemsList.add "li", "columnItem"
            col.gid = col.tag.gid

            col.tagCheck     = col.tag.add "div", "colVisible"
            col.tagName      = col.tag.add "div", "colName"
            col.tagOrderText = col.tag.add "div", "orderText"

            col.tagCheck.setDataPath col.getSource()
            col.tagCheck.on "click", @onClickVisible

        @updateColumnText()

        sortable "#sortedItemsList",
            forcePlaceholderSize: true
            placeholderClass:     'placeholder'

        sortable('#sortedItemsList')[0].addEventListener 'sortupdate', (e)=>

            console.log "SORT UPDATE:", e.detail
            order = 0
            for el in @sortItemsList.el.children()
                id = $(el).data("id")

                for col in @columns
                    if col.getAlwaysHidden() then continue
                    if col.gid != id then continue

                    oldOrder = col.getOrder()
                    if oldOrder != order
                        DataMap.changeColumnAttribute @tableName, col.getSource(), "order", order
                        console.log "Change #{col.getSource()} order from #{oldOrder} to #{order}"

                    order++

            @updateColumnText()
            true

        @onButton1 = (e)=>
            @hide()
            true

        @onButton2 = ()=>
            @hide()
            true

