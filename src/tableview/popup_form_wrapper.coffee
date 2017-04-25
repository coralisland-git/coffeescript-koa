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
    super()
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

