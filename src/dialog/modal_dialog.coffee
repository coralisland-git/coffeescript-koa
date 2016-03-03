substringMatcher = (strs) ->
	return (q, cb) ->
		matches = []
		substrRegex = new RegExp(q, 'i')
		for o in strs
			if substrRegex.test o
				matches.push o
		cb matches

class FormField

	constructor: (@fieldName, @label, @value, @type, @attrs = {}) ->
		@html = @getHtml()

	getHtml: () =>
		return "<input name='#{@fieldName}' id='#{@fieldName}' type='#{@type}' value='#{@value}' class='form-control' />"

	makeTypeahead: (options) =>
		@typeaheadOptions = options

	onPressEnter: () =>
		## do nothing

	onPressEscape: () =>
		## do nothing

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


class FormWrapper

	constructor: () ->
		@fields = []
		@gid    = "form" + GlobalValueManager.NextGlobalID()

		@templateFormFieldText = Handlebars.compile '''
			<div class="form-group">
				<label for="{{fieldName}}"> {{label}} </label>
				<input class="form-control" type="{{type}}" id="{{fieldName}}" value="{{value}}" name="{{fieldName}}"
				{{#each attrs}}
    			{{@key}}="{{this}}"
				{{/each}}
				/>
				<br>
				<div id="{{fieldName}}error" class="text-danger"></div>
			</div>
		'''

	##|
	##|  Add a text input field
	addTextInput: (fieldName, label, value,attrs, fnValidate) =>
		@addInput(fieldName,label,value,"text",attrs,fnValidate)

	##| Add general input field
	addInput: (fieldName, label, value, type = "text",attrs = {},fnValidate) =>
		type = if type is "boolean" then "checkbox" else type
		if type is "checkbox" and value is 1
			attrs.checked = "checked"
		value = if type is "checkbox" then 1 else value
		field = new FormField(fieldName, label,value, type, attrs)
		@fields.push(field)
		return field
	##|
	##|  Generate HTML
	getHtml: () =>

		content = "<form id='#{@gid}'>"

		for field in @fields
			content += @templateFormFieldText(field)

		content += "</form>";

	onSubmit: () =>
		console.log "SUBMIT"

	onSubmitAction: (e) =>
		for field in @fields
			console.log field.el.val(),field.fieldName
			this[field.fieldName] = field.el.val()
		@onSubmit(this)
		if e?
			e.preventDefault()
			e.stopPropagation()

		return false

	onAfterShow: () =>

		@elForm = $("##{@gid}")
		firstField = null
		for field in @fields
			field.el = @elForm.find("##{field.fieldName}")
			field.onAfterShow()
			if !firstField
				firstField = field
				firstField.el.focus()

			field.onPressEnter = (e)=>
				@onSubmitAction(e)

		@elForm.on "submit", @onSubmitAction
		true

class ModalDialog

	content:      "Default content"
	title:        "Default title"
	ok:           "Ok"
	close:        "Close"
	showFooter:   true
	showOnCreate: true
	position:     'top'
	formWrapper:  null

	makeFormDialog: () =>

		@close = "Cancel"

	getForm: () =>

		if !@formWrapper? or !@formWrapper
			@formWrapper = new FormWrapper()

		return @formWrapper

	constructor:  (options) ->

		@gid = GlobalValueManager.NextGlobalID()

		@template = Handlebars.compile '''
			<div class="modal" id="modal{{gid}}" tabindex="-1" role="dialog" aria-hidden="true" style="display: none;">
				<div class="modal-dialog">
					<div class="modal-content">
						<div class="block block-themed block-transparent remove-margin-b">
							<div class="block-header bg-primary-dark">
								<ul class="block-options">
									<li>
										<button data-dismiss="modal" type="button"><i class="si si-close"></i></button>
									</li>
								</ul>
								<h3 class="block-title">{{title}}</h3>
							</div>
							<div class="block-content">
								<p>
								{{{content}}}
								</p>
							</div>
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

	onClose: () =>
		true

	onButton1: () =>
		console.log "Default on button 1"
		@hide();
		true

	onButton2: (e) =>
		if @formWrapper?
			@formWrapper.onSubmitAction(e)
		else
			console.log "Default on button 2"

		@hide();
		true

	hide: () =>
		@modal.modal('hide')

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

class ModalMessageBox extends ModalDialog

	content:      "Default content"
	title:        "Default title"
	ok:           "Ok"
	close:        "Close"
	showFooter:   true
	showOnCreate: true

	constructor: (message) ->

		@showOnCreate = false
		super()

		@title    = "Information"
		@position = 'center'
		@ok       = 'Close'
		@close    = ''
		@content  = message

		@show()

class ErrorMessageBox extends ModalDialog

	content:      "Default content"
	title:        "Default title"
	ok:           "Ok"
	close:        "Close"
	showFooter:   true
	showOnCreate: true

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


