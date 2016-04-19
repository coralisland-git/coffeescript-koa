## -------------------------------------------------------------------------------------------------------------
## Popup window with Form widget
## This class creates a popup window with form that can be used to edit table row.
##
## @example
## 		popup = new PopupForm(tableName, keyColumnSource, Key, columns, defaultValues)
## @extends [FormWrapper]
##
class PopUpFormWrapper extends FormWrapper

	## -------------------------------------------------------------------------------------------------------------
	## constructor
	##
	constructor: () ->

		# @property [Array] fields the collection of fields to show
		@fields = []

		# @property [String] gid the unique key for the current form
		@gid = "form" + GlobalValueManager.NextGlobalID()

		# @property [String] templateFormFieldText the template for the form field
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

		# @property [String] templateFormFieldSelect template for select field
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

	## -------------------------------------------------------------------------------------------------------------
	## get the html of the current form in form of string
	##
	## @return [String] content the html string of the current form
	##
	getHtml: () =>
		content = "<form id='#{@gid}' class='form-horizontal'>"

		for field in @fields
			content += if field.type is "select" then @templateFormFieldSelect(field) else @templateFormFieldText(field)

		content += "</form>";


## -------------------------------------------------------------------------------------------------------------
## class to handle form in the popup
##
## @extends [ModalDialog]
##
class PopupForm extends ModalDialog

	# @property [Boolean] showOnCreate if to show automatically
	showOnCreate: false

	# @property [String] content the html of the current form
	content: ""

	# @property [String] close the content of the close button
	close: "Cancel"

	## -------------------------------------------------------------------------------------------------------------
	## constructor to create new popupform
	##
	## @param [String] tableName name of the table for which form is used
	## @param [String] keyElement name of the key property used to track single row in the table
	## @param [String] key current key value which is being edited
	## @param [Array] columns the array of the columns which should be included in the form
	## @param [Object] defualts the default values for each column in the input
	##
	constructor: (@tableName, @keyElement, @key, @columns, @defaults) ->
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

	## -------------------------------------------------------------------------------------------------------------
	## function to create input fields
	##
	##
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
		for column in @columns
			if column.source is @keyElement
				@keyColumn = column
			value = if @key then DataMap.getDataField(@tableName, @key, column.source) else null
			if @defaults and @defaults[column.source]
				value = @defaults[column.source]
			@formWrapper.addInput column.source, column.name, value, (if !column.element then column.type else column.element), if column.options? then {options: column.options}

	## -------------------------------------------------------------------------------------------------------------
	## function to be executed on the click of button2
	##
	## @param [Event] e the event object
	## @param [Object] form the values filled in the input as object
	## @event onButton2
	##
	onButton2: (e, form) ->
		valid = true
		invalidColumns = [];
		for column in @columns
			if column.required && ( !form[column.source] || form[column.source].length == 0 )
				valid = false
				invalidColumns.push column.name
		##| required fields are not supplied
		if !valid
			alert("#{invalidColumns} are required")
			false
		else
			##| update data
			if @key
				for column in @columns
					DataMap.getDataMap().updatePathValue ["", @tableName, @key,
						column.source].join("/"), form[column.source]
				@hide()
			##| create new data
			else
				##| onCreate callback returns true then add data to datamap
				if @onCreateNew(@tableName, form)
					DataMap.addData @tableName, form[@keyElement], form
					@hide()
