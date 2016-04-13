##| TableEditor Widget to render table column editor
##| example usage:
##| holder where table will be render, key which will be considered in data type
##| te = new TableEditor($('#test'), "zipcode");

class TableEditor

  allowButtons : true

  onCreate: false

  constructor: (@tableHolder,@editedTableKey) ->

    ##| add div for table inside @tableHolder
    if !@tableHolder.length
      console.error "The element with selector #{@tableHolder.selector} not found"
    _dm = DataMap.getDataMap()

    if !@editedTableKey or !_dm.types[@editedTableKey]
      throw new Error "invalid table key #{@editedTableKey} is supplied"

    @rowsList = _dm.types[@editedTableKey].col
    @gid = GlobalValueManager.NextGlobalID()

    _tableElement = $ "<div />"
      .attr('id',"_editor#{@gid}")
      .attr('data-id',"_editor#{@gid}")

    @tableHolder.append _tableElement

    @editorTable = new TableView _tableElement
    @setDataTypes()
    @editorTable.addTable "_editor_#{@editedTableKey}"
    @editorTable.showFilters = false
    @editorTable.render()

    if @allowButtons
      @createButtons()

  clear: ->
    @tableHolder.html ""

  setDataTypes: () ->
    ##| These data type will be same for all the table editor
    DataMap.setDataTypes "_editor_#{@editedTableKey}", [
      {
        name: "Name"
        source: "name"
        visible: true,
        type: "text"
        editable:true
        required:true
        width:120
      }
      {
        name: "Source"
        source: "source"
        visible: true,
        type: "text"
        editable:true
        width:120
      }
      {
        name: "Visible"
        source: "visible"
        visible: true,
        type: "boolean"
        editable:true
        width:120
      }
      {
        name: "Hideable"
        source: "hideable"
        visible: true,
        type: "boolean"
        editable:true
        width:120
      }
      {
        name: "Type"
        source: "type"
        visible: true,
        type: "enum"
        editable:true
        required:true
        width:120,
        element:"select",
        options: Object.keys globalDataFormatter.formats
      }
      {
        name: "Width"
        source: "width"
        visible: true,
        type: "text"
        editable:true
        width:120
      }
      {
        name: "Tooltip"
        source: "tooltip"
        visible: true,
        type: "text"
        editable:true
        width:120
      }
      {
        name: "Sortable"
        source: "sortable"
        visible: true,
        type: "boolean"
        editable:true
        width:120
      }
      {
        name: "Required"
        source: "required"
        visible: true,
        type: "boolean"
        editable:true
        width:120
      }
      {
        name: "Render"
        source: "render"
        visible: true,
        type: "sourcecode"
        editable:true
        width:120
      }
    ]

    ##| add row data to dataMap about current column configurations

    for key,_row of @rowsList
      _preparedRow = @filterRowValues(_row)
      DataMap.addData "_editor_#{@editedTableKey}", _row.source, _preparedRow

  filterRowValues: (_row) ->
    _preparedRow = {}
    _rowElements = ["name","source","visible","hideable","type","width","tooltip","sortable","render"]
    for _element in _rowElements
      _preparedRow[_element] = _row[_element]
    _preparedRow

  createButtons: ->
    _button1 = $('<button />')
      .addClass 'btn btn-success'
      .text "Create New"
      .attr 'id', "_editor_#{@editedTableKey}_create"
    _button2 = $('<button />')
      .addClass 'btn btn-primary'
      .text "Save"
      .attr 'id', "_editor_#{@editedTableKey}_save"
      .css 'margin-left','10px'

    @tableHolder.prepend _button2
      .prepend _button1

    @setButtonEvents()

  setButtonEvents: ->
    _table = @editorTable
    $("#_editor_#{@editedTableKey}_create").on "click", =>
      p = new PopupForm("_editor_#{@editedTableKey}","source",null,null,{visible:1,hideable:1,required:0,sortable:1,type:"text"})
      p.onCreateNew = (tableName, data) =>
        ##| update data map data types if new inserted and add in rowList
        DataMap.setDataTypes tableName,[data]
        DataMap.setDataTypes @editedTableKey,[data]
        @rowsList[data.source] = data
        ##| apply filter or sorting to update the newly create row
        setTimeout () ->
          _table.applyFilters()
        ,1
        if @onCreate and typeof @onCreate is 'function'
          @onCreate(data)
        else
          true

    $("#_editor_#{@editedTableKey}_save").on "click", =>
      _currentConfig = []
      for key, _row of @rowsList
        _currentConfig.push @filterRowValues(_row)
      new ModalDialog
          title:   "Table Configurations"
          content: "<textarea id='_pretty_print#{@editedTableKey}' cols='50' rows='50' class='form-control'>#{JSON.stringify(_currentConfig, undefined, 4);}</textarea>"
