$ ->

	addTestButton "Simple Form View", "Open", () ->
		addHolder "renderTest1"
		div = new WidgetTag "div", "testWidget"
		div.appendTo "#renderTest1"
		div.setView "Form", (view) ->
			view.init()
			view.getForm().addTextInput "input1", "Example Input 1"
			view.getForm().addTextInput "input2", "Example Input 2"
			view.getForm().addSubmit "submit", "Click this button to submit", "Submit"
			view.getForm().onSubmit = (form) =>
				alert "Form Submitted Successfully!\nTest value1 = #{form.input1},  Test Value2 = #{form.input2}"
			view.show()

	addTestButton "Form on Popup", "Open", () ->
		doPopupView "Form", "Form-Popup", "form-popup", 399, 300
		.then (view) ->
			view.init()
			view.getForm().addTextInput "input1", "Example Input 1"
			view.getForm().addTextInput "input2", "Example Input 2"
			view.getForm().addSubmit "submit", "Click this button to submit", "Submit"
			view.getForm().onSubmit = (form) =>
				alert "Form Submitted Successfully!\nTest value1 = #{form.input1},  Test Value2 = #{form.input2}"
			view.show()
		true

	addTestButton "Form in Tab", "Open", () ->
		addHolder "renderTest1"
		tabs = new DynamicTabs "#renderTest1"
		tabs.doAddViewTab("Form", "FormViewTab", (view)->
			view.init()
			view.getForm().addTextInput "input1", "Example Input 1"
			view.getForm().addTextInput "input2", "Example Input 2"
			view.getForm().addSubmit "submit", "Click this button to submit", "Submit"
			view.getForm().onSubmit = (form) =>
				alert "Form Submitted Successfully!\nTest value1 = #{form.input1},  Test Value2 = #{form.input2}"
			view.show()
		)
		tabs.addTab "EmptyTab", 'Another tab'	
		true

	go()
	