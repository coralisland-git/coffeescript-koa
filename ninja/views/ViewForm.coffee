
class ViewForm extends View

	boundaryValueToFullWidth: 400

	getDependencyList: ()=>

	onSetupButtons: () =>

	onShowScreen: ()=>

	## ----------------------------------------------------------------
	## Initialization function
	## Create instance of FormWrapper which would present form
	## 
        
	init: (@optionsData)=>    	
		@elHolder.find(".form-container").html("<div id='formView#{@gid}'/>")
		@form = new FormWrapper @elHolder.find("#formView#{@gid}"), true
		@on "resize", @onResizeFormView
		true

	## -----------------------------------------------------------------
	## Function to regulate "responsiveness" of form elements while resizing
	## When width of form gets shorter than boundary value, elements get wider
	## so that they have full width
	## Also when width of form gets longer than boundary value, elements get narrower
	##
	onResizeFormView : (w, h)=>
		if w == 0 or h == 0 then return
		if w < @boundaryValueToFullWidth
			console.log "Form width < 400"
			@form.putElementsFullWidth()
		else
			console.log "Form width > 400"
			@form.backElementsFullWidth()

	## ---------------------------------------------------------------------
	## Function to set size of form view
	## yet meaningless
	##		
	setSize: (w, h)=>
		@onResizeFormView w, h
		@elHolder.width(w)
		@elHolder.height(h)

    ## ---------------------------------------------------------------------
    ## Function that creates/returns reference to formwrapper
    ## @return [FormWrapper]
    ##
	getForm: () =>
    	if @form? 
    		return @form
    	return new FormWrapper(@elHolder.find("#formView#{@gid}"), true)

    ## ----------------------------------------------------------------------
    ## Function to show rendered form view
    ## @return [Boolean]
    ##
	show: (name)=>
        @form.show()
        @onResizeFormView @elHolder.width(), @elHolder.height()
        true
