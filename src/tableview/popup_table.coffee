##| PopupTable Widget to display table in popup with x,y scrolling
##| usage:
## TableView object, tablename
#  popupTable = new PopupTable(zipcodeTable,'demoZipcodeTable')

class PopupTable extends PopupWindow
  popupWidth: 400
  popupHeight: 300
  isVisible:   true
  allowHorizontalScroll: true

  constructor: (@mainTableObject, @popupName) ->
    _title = "popup Table"
    super _title
    ##| check if virtual element or actual element given
    if @mainTableObject.elTableHolder.attr('id')
      _tableId = @mainTableObject.elTableHolder.attr('id')
    else
      _tableId = @mainTableObject.elTableHolder.selector.substr 1

    @windowScroll.html "<div id='#{_tableId}'></div>"
    ##| assign tableHolder again to detect inside popup and render
    @mainTableObject.elTableHolder = $ "##{_tableId}"
    @mainTableObject.render()
