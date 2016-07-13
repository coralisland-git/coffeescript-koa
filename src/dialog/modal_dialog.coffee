## -------------------------------------------------------------------------------------------------------------
## function to get function with the matcher regex object
##
## @param [Array] strs arra of strings to handle
## @return [Function] function to check match against the passed strings
##
substringMatcher = (strs) ->
	return (q, cb) ->
		matches = []
		substrRegex = new RegExp(q, 'i')
		for o in strs
			if substrRegex.test o
				matches.push o
		cb matches


## -------------------------------------------------------------------------------------------------------------
## class FormField to handle the single FormField and its rendering
##
class FormField

	## -------------------------------------------------------------------------------------------------------------
	## constructor
	##
	## @param [String] fieldName name of the field to give inside html
	## @param [String] label label to be displayed before the form field
	## @param [String] value the initial value to be set in the form field
	## @param [String] type the value of the parameter can be any valid type attribute value for ex. text|radio|checkbox etc.
	## @param [Object] attrs additional attributes to render during the render
	##
	constructor: (@fieldName, @label, @value, @type, @attrs = {}) ->
		@html = @getHtml()

	## -------------------------------------------------------------------------------------------------------------
	## returns the compiled html of the current form field
	##
	## @return [String] compiled html string
	##
	getHtml: () =>
		return "<input name='#{@fieldName}' id='#{@fieldName}' type='#{@type}' value='#{@value}' class='form-control' />"

	## -------------------------------------------------------------------------------------------------------------
	## function to make current form field into typeahead
	##
	## @param [Object] options options that to be used inside typeahead
	##
	makeTypeahead: (options) =>
		@typeaheadOptions = options

	## -------------------------------------------------------------------------------------------------------------
	## callback function to be called when enter is pressed
	##
	onPressEnter: () =>
		## do nothing

	## -------------------------------------------------------------------------------------------------------------
	## callback funciton to be called when escape key is pressed
	##
	onPressEscape: () =>
		## do nothing

	## -------------------------------------------------------------------------------------------------------------
	## function to be called after the element is visible on the screen
	##
	onAfterShow: () =>

		if @typeaheadOptions?
			@el.addClass ".typeahead"
			@el.typeahead
				hint: true
				highlight: true
				minLength: 1
			,
				name: 'options'
				source: substringMatcher(@typeaheadOptions)

			@el.bind "typeahead:select", (ev, suggestion) =>
				console.log "DID CHANGE:", suggestion

		@el.bind "keypress", (e) =>
			if e.keyCode == 13
				@onPressEnter(e)
				return false

			if e.keyCode == 27
				@onPressEscape(e)
				return false

			return true


## -------------------------------------------------------------------------------------------------------------
## class FormWrapper to handle the entire form with FormField
##
class FormWrapper

	## -------------------------------------------------------------------------------------------------------------
	## constructor
	##
	constructor: () ->
		# @property [Array] fields fields currently included in the formWrapper
		@fields = []

		# @property [String] gid unique id of the formWrapper
		@gid    = "form" + GlobalValueManager.NextGlobalID()

		# @property [String] templateFormFieldText template to use in the render of form
		@templateFormFieldText = Handlebars.compile '''
			<div class="form-group">
				<label for="{{fieldName}}" class='control-label col-sm-2'> {{label}} </label>
				<div class='col-sm-10'>
					<input class="form-control" type="{{type}}" id="{{fieldName}}" value="{{value}}" name="{{fieldName}}"
					{{#each attrs}}
					{{@key}}="{{this}}"
					{{/each}}
					/>
					<div id="{{fieldName}}error" class="text-danger"></div>
				</div>
			</div>
		'''

	## -------------------------------------------------------------------------------------------------------------
	## Add a text input field
	##
	## @param [String] fieldName name of the input field
	## @param [String] label label to be displayed infornt of text input
	## @param [String] value default value to be filled
	## @param [Object] attrs object as attributes that will be included in the html
	## @param [Function] fnValidate a validation function can be passed if it returns true value will be valid else invalid
	##
	addTextInput: (fieldName, label, value,attrs, fnValidate) =>
		@addInput(fieldName,label,value,"text",attrs,fnValidate)

	## -------------------------------------------------------------------------------------------------------------
	## Add a text input field
	##
	## @param [String] fieldName name of the input field
	## @param [String] label label to be displayed infornt of text input
	## @param [String] value default value to be filled
	## @param [Object] attrs object as attributes that will be included in the html
	## @param [Function] fnValidate a validation function can be passed if it returns true value will be valid else invalid
	##
	addTagsInput: (fieldName, label, value, attrs, fnValidate) =>

		field = @addInput(fieldName, label, value, "text", attrs, fnValidate)

		field.superAfterShow = field.onAfterShow
		field.onAfterShow = ()->

			@el.selectize
				plugins: ['remove_button']
				delimiter: ','
				persist: false
				create: (input) ->
					console.log "Adding[#{input}]"
					return { value: input, text: input }

			@superAfterShow()

		field

	## -------------------------------------------------------------------------------------------------------------
	## Add a general input field
	##
	## @param [String] fieldName name of the input field
	## @param [String] label label to be displayed infornt of text input
	## @param [String] value default value to be filled
	## @param [String] type type of the input it can be any valid type attribute value default is text
	## @param [Object] attrs object as attributes that will be included in the html
	## @param [Function] fnValidate a validation function can be passed if it returns true value will be valid else invalid
	##
	addInput: (fieldName, label, value, type = "text",attrs = {},fnValidate) =>
		type = if type is "boolean" then "checkbox" else type
		if type is "checkbox" and value is 1
			attrs.checked = "checked"
		value = if type is "checkbox" then 1 else value
		field = new FormField(fieldName, label,value, type, attrs)
		@fields.push(field)
		return field

	## -------------------------------------------------------------------------------------------------------------
	## Generate html for the formWrapper
	##
	## @return [String] content the html content after compilation under handlebar
	##
	getHtml: () =>

		content = "<form id='#{@gid}' class='form-horizontal' role='form'>"

		for field in @fields
			content += @templateFormFieldText(field)

		content += "</form>";

	## -------------------------------------------------------------------------------------------------------------
	## function that will be called when a form is submitted
	##
	## @event onSubmit function that will be executed on submit of form
	##
	onSubmit: () =>
		console.log "SUBMIT"

	## -------------------------------------------------------------------------------------------------------------
	## function that will be called on form submit
	##
	## @param [Event] jquery Event object of submitted form
	## @return [Boolean]
	##
	onSubmitAction: (e) =>
		for field in @fields
			console.log field.el.val(),field.fieldName
			this[field.fieldName] = field.el.val()
		@onSubmit(this)
		if e?
			e.preventDefault()
			e.stopPropagation()

		return false

	## -------------------------------------------------------------------------------------------------------------
	## function that will be called after the form is rendered and visible
	##
	## @return [Boolean]
	##
	onAfterShow: () =>

		@elForm = $("##{@gid}")
		firstField = null
		for field in @fields
			field.el = @elForm.find("##{field.fieldName}")
			console.log "Calling onAfterShow for field:", field
			field.onAfterShow()
			if !firstField
				firstField = field
				firstField.el.focus()

			field.onPressEnter = (e)=>
				console.log "field.onPressEnter:", e
				@onSubmitAction(e)

		@elForm.on "submit", @onSubmitAction
		true


## -------------------------------------------------------------------------------------------------------------
## class ModalDialog to handle the modal
##
class ModalDialog
	# @property [String] content the content of the modal defualt is Default Content
	content:      "Default content"

	# @property [String] title the title of the modal dialog default is Default Title
	title:        "Default title"

	# @property [String] ok the content to show on the ok button default is Ok
	ok:           "Ok"

	# @property [String] close the content to show on the close button default is close
	close:        "Close"

	# @property [Boolean] showFooter if the footer should be shown or not
	showFooter:   true

	# @property [Boolean] showOnCreate if the modal should be shown after created automatically
	showOnCreate: true

	# @property [String] position the position of the modal to display default is top
	position:     'top'

	# @property [FormWrapper|null] formWrapper formWrapper to display inside the modal
	formWrapper:  null

	## -------------------------------------------------------------------------------------------------------------
	## function to make the formDialog
	##
	makeFormDialog: () =>

		@close = "Cancel"

	## -------------------------------------------------------------------------------------------------------------
	## function to get the form object as formWrapper
	##
	## @return [FormWrapper] formWrapper
	##
	getForm: () =>

		if !@formWrapper? or !@formWrapper
			@formWrapper = new FormWrapper()

		return @formWrapper

	## -------------------------------------------------------------------------------------------------------------
	## constructor
	##
	## @param [Object] options any valid property can be used inside object
	##
	constructor:  (options) ->

		@gid = GlobalValueManager.NextGlobalID()

		@template = Handlebars.compile '''
			<div class="modal" id="modal{{gid}}" tabindex="-1" role="dialog" aria-hidden="true" style="display: none;">
				<div class="modal-dialog">
					<div class="modal-content">
						<div class="modal-header bg-primary">
							<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
							<h4 class="modal-title">{{title}}</h4>
						</div>
						<div class="modal-body">
							<p>
							{{{content}}}
							</p>
						</div>

						{{#if showFooter}}
						<div class="modal-footer">
							{{#if close}}
							<button class="btn btn-sm btn-default btn1" type="button" data-dismiss="modal">{{close}}</button>
							{{/if}}
							{{#if ok}}
							<button class="btn btn-sm btn-primary btn2" type="button" data-dismiss="modal"><i class="fa fa-check"></i> {{ok}}</button>
							{{/if}}
						</div>
						{{/if}}

					</div>
				</div>
			</div>
		'''

		##
		##  Possibly overwrite default options
		if typeof options == "object"
			for name, val of options
				this[name] = val

		if @showOnCreate
			@show()

	## -------------------------------------------------------------------------------------------------------------
	## function to execute on the close of the modal
	##
	## @event onClose
	## @return [Boolean]
	##
	onClose: () =>
		true

	## -------------------------------------------------------------------------------------------------------------
	## function to execute on the click of button1
	##
	## @event onButton1
	## @return [Boolean]
	##
	onButton1: () =>
		console.log "Default on button 1"
		@hide();
		true

	## -------------------------------------------------------------------------------------------------------------
	## function to execute on the click of button2
	##
	## @event onButton2
	## @return [Boolean]
	##
	onButton2: (e) =>
		if @formWrapper?
			@formWrapper.onSubmitAction(e)
		else
			console.log "Default on button 2"

		@hide();
		true

	## -------------------------------------------------------------------------------------------------------------
	## function to hide the modal
	##
	##
	hide: () =>
		@modal.modal('hide')

	## -------------------------------------------------------------------------------------------------------------
	## function to show the modal
	##
	## @param [Object] options options to be used in showing the modal
	## @return [Boolean]
	##
	show: (options) =>

		if @formWrapper?
			@content += @formWrapper.getHtml()

		html = @template(this)
		$("body").append html

		@modal = $("#modal#{@gid}")
		@modal.modal(options)
		@modal.on "hidden.bs.modal", () =>
			##|
			##|  Remove HTML from body
			@modal.remove()

			##|
			##|  Call the close event
			@onClose()

		@modal.find(".btn1").bind "click", () =>
			@onButton1()

		@modal.find(".btn2").bind "click", (e) =>
			e.preventDefault()
			e.stopPropagation()

			options = {}
			@modal.find("input,select").each (idx, el) =>
				name = $(el).attr("name")
				val  = $(el).val()
				options[name] = val

			if @onButton2(e, options) == true
				@onClose()

			true

		##|
		##| -------------------------------- Position of the dialog ---------------------------

		if @position == "center"

			@modal.css
				'margin-top' : () =>
					Math.max(0, ($(window).scrollTop() + ($(window).height() - @modal.height()) / 2 ))

		if @formWrapper?
			setTimeout ()=>
				@formWrapper.onAfterShow()
			, 10


## -------------------------------------------------------------------------------------------------------------
## class ModalMessageBox to show modal as message box
##
## @extends [ModalDialog]
##
class ModalMessageBox extends ModalDialog

	# @property [String] content the content of the modal
	content:      "Default content"

	# @property [String] title the title of the modal
	title:        "Default title"

	# @property [String] ok text of the button1
	ok:           "Ok"

	# @property [String] close text of the button2
	close:        "Close"

	# @property [Boolean] showFooter to show footer or not
	showFooter:   true

	# @property [Boolean] showOnCreate
	showOnCreate: true

	## -------------------------------------------------------------------------------------------------------------
	## constructor
	##
	## @param [String] message the message to show in the modal as message
	##
	constructor: (message) ->

		@showOnCreate = false
		super()

		@title    = "Information"
		@position = 'center'
		@ok       = 'Close'
		@close    = ''
		@content  = message

		@show()


## -------------------------------------------------------------------------------------------------------------
## class ErrorMessageBox to show the errors in the modal dialog
##
##
## @extends [ModalDialog]
class ErrorMessageBox extends ModalDialog

	# @property [String] content the content of the modal
	content:      "Default content"

	# @property [String] title default title
	title:        "Default title"

	# @property [String] ok text of ok button
	ok:           "Ok"

	# @property [String] close text of close button
	close:        "Close"

	# @property [Boolean] showFooter
	showFooter:   true

	# @property [Boolean] showOnCreate
	showOnCreate: true

	## -------------------------------------------------------------------------------------------------------------
	## constructor
	##
	## @param [String] message to show the error message inside modal
	## @return [Boolean]
	##
	constructor: (message) ->

		@showOnCreate = false
		super()

		console.log "MESSAGE=", message

		@title    = "Error"
		@position = 'center'
		@ok       = 'Close'
		@close    = ''
		@content  = message

		@show()
