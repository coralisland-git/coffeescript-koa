## -------------------------------------------------------------------------------------------------------------
## popuptable widget to display table in popup with x,y scrolling
##
## @example
##		popuptable = new PopupTable(zipcodeTable, 'demoZipcodeTable')
## @extends [PopupWindow]
##
class PopupTable extends PopupWindow

	# @property [Integer] popupWidth the width of the popup
    popupWidth: 400

	# @property [Integer] popupHeight the height of the popup
    popupHeight: 300

	# @property [Boolean] isVisible currently rendered on screen
    isVisible: true

	# @property [Boolean] allowHorizontalScroll if horizontal scroll is allowed
    allowHorizontalScroll: true

	## -------------------------------------------------------------------------------------------------------------
	## constructor to create new popupTable
	##
	## @param [TableView] mainTableObject the tableview instance which will be rendered inside popup
	## @param [String] popupName name of the popup to be rendered
	##
    constructor: (@mainTableObject, @popupName, renderParam = null) ->
        _title = "popup Table"
        super _title
        ##| check if virtual element or actual element given
        if @mainTableObject.elTableHolder.attr('id')
            _tableId = @mainTableObject.elTableHolder.attr('id')
        else
            _tableId = @mainTableObject.elTableHolder.selector.substr 1
        ##| assign the prefix popup so elements get seperated from direct body elements
        _tableId += "popup_#{_tableId}"

        @windowScroll.html "<div id='#{_tableId}'></div>"
        ##| assign tableHolder again to detect inside popup and render
        @mainTableObject.elTableHolder = $ "##{_tableId}"
        @mainTableObject.render(renderParam)
        @center()
