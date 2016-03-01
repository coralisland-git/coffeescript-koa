##|
##|  Popup window With Form widget
##|
##|  This class creates a popup window with form that can be used to edit table row.
##|
##|  @example
##|      popup = new PopupForm(tableName, keyColumnSource, key, columns)
##|


class PopupForm extends ModalDialog

  showOnCreate: false;
  content:      ""
  close:        "Cancel"

  constructor: (@tableName, @keyElement,@key, @columns) ->
    if !@keyElement
      throw new Error "Key name is not supplied in the PopupForm"

    @title = if @key then 'Edit ' else 'Create '
    @ok = if @key then 'Save Changes' else 'Create New'
    super()

    if !@columns
      @columns = DataMap.getColumnsFromTable @tableName, (c) ->
                  c.editable

    ##| get formWrapper object
    @getForm()

    ##| generate text fields
    @createTextFields()

    @show()

  createTextFields: () ->
    ##| if in create mode insert key column and make it required
    if !@key
      @keyColumn = DataMap.getColumnsFromTable @tableName, (c) =>
        c.source is @keyElement
      .pop()
      ##| make key column required
      @keyColumn.required = true
      @columns.unshift @keyColumn
    @columns = $.unique(@columns);
    for _column in @columns
      if _column.source is @keyElement
        @keyColumn = _column
      @formWrapper.addTextInput _column.source,_column.name,DataMap.getDataField(@tableName,@key,_column.source)

  onButton2 : (e,form) ->
    _valid = true
    _invalidColumns = [];
    for _column in @columns
      if _column.required && ( !form[_column.source] || form[_column.source].length == 0 )
        _valid = false
        _invalidColumns.push _column.name
    ##| required fields are not supplied
    if !_valid
      alert("#{_invalidColumns} are required")
      false
    else
      ##| update data
      if @key
        for _column in @columns
          DataMap.getDataMap().updatePathValue ["", @tableName, @key, _column.source].join("/"), form[_column.source]
        @hide()
      ##| create new data
      else
        ##| onCreate callback returns true then add data to datamap
        if @onCreateNew(@tableName,form)
          DataMap.addData @tableName, form[@keyElement], form
          @hide()

