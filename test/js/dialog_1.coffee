$ ->

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

	addTestButton "Simple Form 1", "Open", () ->

		m = new ModalDialog
			showOnCreate: false
			content:      "Fill out this example form"
			position:     "center"
			title:        "Form Title"
			ok:           "Go"

		m.addTextInputField "input1", "Example Input 1"
		m.show()

	addTestButton "Simple Form 2", "Open", () ->

		m = new ModalDialog
			showOnCreate: false
			content:      "Fill out this example form"
			title:        "Form Title"
			ok:           "Go"

		m.addTextInputField "input1", "Example Input 1"
		m.addTextInputField "input2", "Example Input 2"
		m.addTextInputField "input3", "Example Input 3"

		m.onButton2 = (e, fields) ->
			console.log "FIELDS=", fields
			m.hide()
			return true

		m.show()


	go()