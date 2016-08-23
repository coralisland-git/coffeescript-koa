## -------------------------------------------------------------------------------------------------------------
## popuptable widget to display table in popup with x,y scrolling
##
## @example
##		popuptable = new PopupTable(zipcodeTable, 'demoZipcodeTable')
## @extends [PopupWindow]
##

###
class ViewShowTable extends View

    onSetupButtons: () =>

    onShowScreen: ()=>

    onResize: (pw, ph)=>
        h = @elHolder.parent().parent().height()
        @table.elTableHolder.height h
        @table.render()
        true

    loadTable: (tableName) =>

        @popup.on "resize", @onResize

        @gid = GlobalValueManager.NextGlobalID()
        @tableHolder = $ "<div id='realPopupTable#{@gid}'></div>"
        @elHolder.html @tableHolder

        @table = new TableView @tableHolder
        @table.addTable tableName
        @table.setFixedHeaderAndScrollable()
        @onResize(0,0)

        true

###

class PopupTable extends PopupWindow

    onResizeTable: (pw, ph)=>
        # console.log "OnResizeTable pw=#{pw} ph=#{ph}"
        # console.log "my size=", @windowWrapper.width(), @windowWrapper.height()
        @windowScroll.width(@windowWrapper.width())
        @windowScroll.height(@windowWrapper.height())
        @table.onResize()

	## -------------------------------------------------------------------------------------------------------------
	## constructor to create new popupTable
	##
	## @param [TableView] mainTableObject the tableview instance which will be rendered inside popup
	## @param [String] popupName name of the popup to be rendered
	##
    constructor: (@primaryTable, title, x, y, w, h, options) ->

        if !w? then w = 400
        if !h? then h = 400

        @config =
            w              : w
            h              : h
            showCheckboxes : false
            scrollable     : false

        $.extend @config, options

        super title, x, y, @config

        @on "resize", @onResizeTable

        @windowScroll.css
            "width" : "100%"
            "height" : "100%"

        @table = new TableView @windowScroll, @config.showCheckboxes
        @table.addTable @primaryTable
        @table.setFixedHeaderAndScrollable()
        @table.render()


        # console.log "h2=", @windowScroll.parent().height(), @windowScroll.parent()
        # console.log "h3=", @windowScroll.parent().parent().height(), @windowScroll.parent().parent()