## ----------------------------------------------------------------------------------------------
## Class for showing modal dialog with a view
## Here, this view can have a form 

class ModalViewDialog extends ModalDialog
	## ------------------------------------------------------------------------------------------
	## Just same as ModalDialog except this needs to create a view
	constructor: (options) ->
		super(options)
		@view = new View()

	## ------------------------------------------------------------------------------------------
	## function to show modal, override ModalDialog's
	## add a view into content of modal's body
	## add a form into the view above
	##
	## @param [Object] options: options to be used in showing modal
	## @return [Boolean]
	##
	show: (options) =>
		@content += "<div class='modal_ViewDialog' id='modal_ViewDialog#{@gid}' />"
		@html = @template(this)
		$("body").append @html
		@view.AddToElement "#modal_ViewDialog#{@gid}"
		@view.elHolder.append @getForm().getHtml()	
		
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


