## -------------------------------------------------------------------------------------------------------------
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

#		if @formWrapper?
#			@content += @formWrapper.getContent()

		html = @template(this)
		$("body").append html

		@modal = $("#modal#{@gid}")

		@modal_body = @modal.find(".modal-body")
		@modal_body.append @formWrapper.getContent()

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


