$ ->
	addTest "Loading Zipcodes", () ->

        new Promise (resolve, reject) ->
            ds  = new DataSet "zipcode"
            ds.setAjaxSource "/js/test_data/zipcodes.json", "data", "code"
            ds.doLoadData()
            .then (dsObject)->
                resolve(true)
            .catch (e) ->
                console.log "Error loading zipcode data: ", e
                resolve(false)

	addTestButton "Simple Message Box", "Open", ()->

		m = new ModalMessageBox "Test message box"

	addTestButton "Change Title", "Open", ()->

		m = new ModalDialog
			title:   "Change title test"
			content: "Test message box"

	addTestButton "Change Buttons", "Open", ()->

		m = new ModalDialog
			title:   "Change buttons test"
			content: "Test message box"
			ok:      "I am 1"
			close:   "I am 2"

	addTestButton "Custom Events", "Open", ()->

		m = new ModalDialog
			title:   "Change buttons test"
			content: "Test message box"
			close:   "I am 1"
			ok:      "I am 2"
			onButton1: ()->
				console.log "On Button 1 Custom"
				true
			onButton2: (e)->
				console.log "On Button 2 Custom", e
				true

	addTestButton "Error Message", "Open", ()->

		m = new ErrorMessageBox "Error message text"

	addTestButton "Busy Dialog 1", "Open", ()->

		window.globalBusyDialog.showBusy "Busy doing something for 3 seconds"
		setTimeout ()->
			window.globalBusyDialog.finished()
		, 3000

	addTestButton "Busy Dialog 2", "Open", ()->

		window.globalBusyDialog.showBusy "Busy doing something first"
		setTimeout ()->
			window.globalBusyDialog.showBusy "Busy doing something else"
			setTimeout ()->
				window.globalBusyDialog.finished()
				setTimeout ()->
					##|  Close out the first task
					window.globalBusyDialog.finished()
				, 3000
			, 3000
		, 3000

	addTestButton "Busy Dialog - Percents 1", "Open", ()->

		window.globalBusyDialog.showBusy "Doing something that takes time"
		window.globalBusyDialog.setMinMax(0, 100)

		counter = 0
		do loopRunning = ()->
			window.globalBusyDialog.updatePercent(counter++)
			if counter < 100
				setTimeout loopRunning, 100
			else
				window.globalBusyDialog.finished()

	addTestButton "Simple Form 1", "Open", () ->

		m = new ModalDialog
			showOnCreate: false
			content:      "Fill out this example form"
			position:     "top"
			title:        "Form Title"
			ok:           "Go"

		m.getViewContainer().setView "Form", (view)->
			view.addTextInput "input1", "Example Input 1"
			view.setSubmitFunction (form) =>
				console.log "Submitted form, test value=", form.input1
				m.hide()
			view.show()
			view.setSize 400, 100
		m.show()

	addTestButton "Simple Form 2", "Open", () ->
		m = new ModalDialog
			showOnCreate: false
			content:      "Fill out this example form"
			title:        "Form Title"
			ok:           "Go"

		m.getForm().addTextInput "input1", "Example Input 1"
		m.getForm().addTextInput "input2", "Example Input 2"
		m.getForm().addTextInput "input3", "Example Input 3"
		m.getForm().onSubmit = (form) =>
			console.log "Submitted form, test value 1=", form.input1
			console.log "Submitted form, test value 2=", form.input2
			console.log "Submitted form, test value 3=", form.input3
			m.hide()

		m.onButton2 = (e, fields) ->
			console.log "FIELDS=", fields
			m.hide()
			return true

		m.show()

	addTestButton "Tags Input (Selectize)", "Open", () ->

		m = new ModalDialog
			showOnCreate: false
			content:      "Fill out this example form"
			title:        "Form Title"
			ok:           "Go"

		m.getForm().addTagsInput "input1", "Example Input 1"

		m.getForm().onSubmit = (form) =>
			console.log "Submitted form, test value 1=", form.input1
			m.hide()
		m.show()

	states = ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia',
	'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts',
	'Michigan', 'Minnesota','Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico',
	'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina',
	'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming' ]

	addTestButton "Form Typeahead", "Open", () ->

		m = new ModalDialog
			showOnCreate: false
			content:      "Type part of a state name"
			position:     "top"
			title:        "Typeahead Test"
			ok:           "Go"

		m.getForm().addTextInput "input1", "State"
		.makeTypeahead states

		m.getForm().onSubmit = (form) =>
			console.log "Submitted form, test value=", form.input1
			m.hide()

		m.show()

	addTestButton "ModalViewDialog", "Open", () ->
		m = new ModalViewDialog
			showOnCreate: false
			content:      "Fill out this example form"
			title:        "Form Title"
			ok:           "Go"

		m.getBody().setView "Form", (view)->
			view.addTextInput "input1", "Example Input 1"
			view.addTextInput "input2", "Example Input 2"
			view.addTextInput "input3", "Example Input 3"

			view.setSubmitFunction (form) =>
				console.log "Submitted form, test value 1=", form.input1
				console.log "Submitted form, test value 2=", form.input2
				console.log "Submitted form, test value 3=", form.input3
				m.hide()

		m.onButton2 = (e, fields) ->
			console.log "FIELDS=", fields
			m.hide()
			return true

		m.show()

	go()