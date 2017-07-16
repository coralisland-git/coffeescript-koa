
class ViewForm extends View

	boundaryValueToFullWidth: 400

	getDependencyList: ()=>

	onSetupButtons: () =>

	onShowScreen: ()=>

	## ----------------------------------------------------------------
	## Initialization function
	## Create instance of FormWrapper which would present form
	## 

	init: ()=>    	
		@elHolder.find(".form-container").html("<div id='formView#{@gid}'/>")
		@form = new FormWrapper @elHolder.find("#formView#{@gid}"), true

	## -----------------------------------------------------------------
	## Function to regulate "responsiveness" of form elements while resizing
	## When width of form gets shorter than boundary value, elements get wider
	## so that they have full width
	## Also when width of form gets longer than boundary value, elements get narrower
	##
	onResizeFormView : (w, h)=>
		if w == 0 or h == 0 then return
		if w < @boundaryValueToFullWidth
			@getForm().putElementsFullWidth()
		else
			@getForm().backElementsFullWidth()

	## ---------------------------------------------------------------------
	## Function to set size of form view
	## yet meaningless
	##
	setSize: (w, h)=>
		super(w, h)
		@elHolder.width(w)
		@elHolder.height(h)
		@onResizeFormView w, h

	## ---------------------------------------------------------------------
	## Function that creates/returns reference to formwrapper
	## @return [FormWrapper]
	##
	getForm: () =>
		if @form?
			return @form
		@init()

	## ----------------------------------------------------------------------
	## Function to show rendered form view
	## @return [Boolean]
	##
	show: (name)=>
		@getForm().show()
		true

	## -gao
	## functions to add input fields into Form
	##
	addTextInput: (fieldName, label, value, attrs, fnValidate) =>
		@getForm().addTextInput fieldName, label, value, attrs, fnValidate

	addTagsInput: (fieldName, label, value, attrs, fnValidate) =>
		@getForm().addTagsInput fieldName, label, value, attrs, fnValidate

	addMultiselect: (fieldName, label, value, attrs, fnValidate) =>
		@getForm().addMultiselect fieldName, label, value, attrs, fnValidate

	addInput: (fieldName, label, value, type = "text",attrs = {},fnValidate) =>
		@getForm().addInput fieldName, label, value, type, attrs, fnValidate

	addSubmit: (fieldName, label, value, attrs = {}) =>
		@getForm().addSubmit fieldName, label, value, attrs

	addPathField: (fieldName, tableName, columnName, attrs = {}) =>
		@getForm().addPathField fieldName, tableName, columnName, attrs

	setSubmitFunction: (fn) =>
		if fn and typeof fn is "function"
			@getForm().onSubmit = fn
	
	setPath: (tableName, idValue) =>
		@getForm().setPath tableName, idValue
