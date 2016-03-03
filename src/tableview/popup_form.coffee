##|
##|  Popup window With Form widget
##|
##|  This class creates a popup window with form that can be used to edit table row.
##|
##|  @example
##|      popup = new PopupForm(tableName, keyColumnSource, key, columns, defaultValues)
##|

class PopUpFormWrapper extends FormWrapper

  constructor: () ->
    @fields = []
    @gid    = "form" + GlobalValueManager.NextGlobalID()

    @templateFormFieldText = Handlebars.compile '''
			<div class="form-group">
				<label for="{{fieldName}}" class="col-md-3 control-label"> {{label}} </label>
				<div class="col-md-9">
				  <input type="{{type}}" class="form-control" id="{{fieldName}}" value="{{value}}" name="{{fieldName}}"
          {{#each attrs}}
            {{@key}}="{{this}}"
          {{/each}}
          />
          <div id="{{fieldName}}error" class="text-danger help-block"></div>
        </div>
			</div>
		'''

    @templateFormFieldSelect = Handlebars.compile '''
			<div class="form-group">
				<label for="{{fieldName}}" class="col-md-3 control-label"> {{label}} </label>
				<div class="col-md-9">
				  <select class="form-control" id="{{fieldName}}" name="{{fieldName}}">
            {{#each attrs.options}}
              <option value="{{this}}" {{#if @first}} selected="selected" {{/if}}>{{this}}</option>
            {{/each}}
          </select>
          <div id="{{fieldName}}error" class="text-danger help-block"></div>
        </div>
			</div>
		'''

  ##|
  ##|  Generate HTML
  getHtml: () =>

    content = "<form id='#{@gid}' class='form-horizontal'>"

    for field in @fields
      content += if field.type is "select" then @templateFormFieldSelect(field) else @templateFormFieldText(field)

    content += "</form>";


##| class to get PopupForm
class PopupForm extends ModalDialog

  showOnCreate: false;
  content:      ""
  close:        "Cancel"
  constructor: (@tableName, @keyElement,@key, @columns, @defaults) ->
    if !@keyElement
      throw new Error "Key name is not supplied in the PopupForm"

    @title = if @key then 'Edit ' else 'Create '
    @ok = if @key then 'Save Changes' else 'Create New'
    super()

    if !@columns
      @columns = DataMap.getColumnsFromTable @tableName, (c) ->
                  c.editable
    ##| get formWrapper object
    @formWrapper = new PopUpFormWrapper()

    ##| generate text fields
    @createInputFields()

    @show()

  createInputFields: () ->
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
      _value = if @key then DataMap.getDataField(@tableName,@key,_column.source) else null
      if @defaults and @defaults[_column.source]
        _value = @defaults[_column.source]
      @formWrapper.addInput _column.source,_column.name,_value,(if !_column.element then _column.type else _column.element),if _column.options? then {options:_column.options}

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