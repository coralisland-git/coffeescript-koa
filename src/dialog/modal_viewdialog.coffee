## ----------------------------------------------------------------------------------------------
## Class for showing modal dialog with a view
## Here, this view can have a form 

class ModalViewDialog extends ModalDialog
	## ------------------------------------------------------------------------------------------
	## Just same as ModalDialog except this needs to create a view
	constructor: (options) ->
		super(options)

	## ------------------------------------------------------------------------------------------
	## function to show modal, override ModalDialog's
	## you can add a view into WidgetTag viewContainer
	## after that, you can add a form into the view above
	##
	## @param [Object] options: options to be used in showing modal
	## @return [Boolean]
	##
	show: (options) =>
		$("body").append @modalContainer.getTag()

		@modal = $("#modal#{@gid}")

		@modal_body = @modal.find(".modal-body")

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

	## -gao
	## function to set view of ModalViewDialog
	##
	setView: (@viewName, @viewCallback, @optionalData)=>
		@viewContainer.setView @viewName, @viewCallback, @optionalData

	setFormView : (@viewCallback, @optionalData) =>
		@viewName = "Form"
		@viewContainer.setView @viewName, @viewCallback, @optionalData
