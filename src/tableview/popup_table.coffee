##| PopupTable Widget to display table in popup with x,y scrolling
##| usage:
## TableView object, tablename
#  popupTable = new PopupTable(zipcodeTable,'demoZipcodeTable')

class PopupTable extends PopupWindow
  popupWidth: 120
  popupHeight: 500
  isVisible:   true
  allowHorizontalScroll: true

  constructor: (@mainTableObject, @popupName) ->
    _title = "popup Table"
    super _title
    @windowScroll.html "<div id='#{@mainTableObject.elTableHolder.selector.substr 1}'></div>"
    ##| assign tableHolder again to detect inside popup and render
    @mainTableObject.elTableHolder = $ @mainTableObject.elTableHolder.selector
    @mainTableObject.render()
