class ModalDialog

	content:      "Default content"
	title:        "Default title"
	ok:           "Ok"
	close:        "Close"
	showFooter:   true
	showOnCreate: true
	position:     'top'

	isFormDialog: false

	makeFormDialog: () =>

		@isFormDialog = true
		@content += "<form id='messageBoxForm'>"
		@close = "Cancel"

	##|
	##|  Add a text input field
	addTextInputField: (fieldName, label, fnValidate) =>

		@makeFormDialog()
		@content += @templateFormFieldText
			fieldName: fieldName
			label: label

		if !@firstField?
			@firstField = fieldName

	constructor:  (options) ->

		@gid = GlobalValueManager.NextGlobalID()

		@templateFormFieldText = Handlebars.compile '''
			<div class="form-group">
				<label for="{{fieldName}}"> {{label}} </label>
				<input class="form-control" id="{{fieldName}}" name="{{fieldName}}">
				<br>
				<div id="{{fieldName}}error" class="text-danger"></div>
			</div>
		'''

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

	onButton2: () =>
		console.log "Default on button 2"
		@hide();
		true

	hide: () =>
		@modal.modal('hide')

	show: (options) =>

		if @isFormDialog
			@content += "</form>"

		html = @template(this)
		$("body").append html

		@modal = $("#modal#{@gid}")
		@modal.modal(options)

		if @firstField? and @firstField
			setTimeout ()=>
				$("##{@firstField}").focus()
				$("#messageBoxForm").on "submit", (e) =>
					console.log "SUBMIT"
					@modal.find(".btn2").trigger("click", e)
					e.preventDefault()
					e.stopPropagation()
					return false
			, 200

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
			@modal.find("input").each (idx, el) =>
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


