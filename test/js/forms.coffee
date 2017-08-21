$ ->

	$("body").append '''
	    <style type="text/css">
	    .test_table {
	    	width: 100%;
	    }
	    .test_table td {
	    	border: solid 1px #bbbbdd;
	    	color: #309030;
	    }
	    .lastTable {
	        margin-bottom : 330px;
	    }
	    </style>
	'''
	TableZipcode = []
	TableZipcode.push
	    name        : 'Code'
	    source      : 'code'
	    visible     : true
	    editable    : false
	    type        : 'int'
	    required    : true

	TableZipcode.push
	    name        : 'City'
	    source      : 'city'
	    visible     : true
	    editable    : true
	    type        : 'text'
	    
	TableZipcode.push
	    name        : 'State'
	    source      : 'state'
	    visible     : true
	    editable    : false
	    type        : 'text'
	    
	TableZipcode.push
	    name        : 'County'
	    source      : 'county'
	    visible     : true
	    editable    : false
	    type        : 'text'

	TableZipcode.push
	    name        : 'Latitude'
	    source      : 'lat'
	    visible     : true
	    editable    : true
	    type        : 'float'

	TableZipcode.push
	    name        : 'Longitude'
	    source      : 'lon'
	    visible     : true
	    editable    : true
	    type        : 'float'

	TableTestdata = []
	TableTestdata.push
		name        : "ID"
		source      : "id"
		editable    : false
		required    : true
	TableTestdata.push
		name        : "InitialPrice"
		source      : "initialPrice"
		editable    : false
	TableTestdata.push
		name        : "CurrentPrice"
		source      : "currentPrice"
		editable    : true
	TableTestdata.push
		name        : "Date"
		source      : "date"
		editable    : true
	TableTestdata.push
		name        : "Distance"
		source      : "distance"
		editable    : true
	TableTestdata.push
		name        : "IsNew"
		source      : "isNew"
		editable    : true
	TableTestdata.push
		name 		: "SourceCode"
		source 		: "sourcecode"
		editable	: true
	TableTestdata.push
		name 		: "Memo"
		source 		: "memo"
		editable	: true

	addTest "Loading Data from files..", () ->
        loadZipcodes()
        .then ()->
            DataMap.setDataTypes 'zipcode', TableZipcode
            return true
        loadDatafromJSONFile "testData"
        .then ()->
            DataMap.setDataTypes 'testData', TableTestdata
            return true
        return true

	addTestButton "Simple Form View", "Open", () ->
		addHolder().setView "Form", (view) ->
			view.addTextInput "input1", "Example Input 1"
			view.addTextInput "input2", "Example Input 2"
			view.addSubmit "submit", "", "Submit"
			view.setSubmitFunction (form) =>
				alert "Form Submitted Successfully!\nTest value1 = #{form.input1},  Test Value2 = #{form.input2}"
			view.show()

	addTestButton "Simple Form View Submit Label", "Open", () ->
		addHolder().setView "Form", (view) ->
			view.addTextInput "input1", "Example Input 1"
			view.addTextInput "input2", "Example Input 2"
			view.addSubmit "submit", "Submit Label", "Submit"
			view.setSubmitFunction (form) =>
				alert "Form Submitted Successfully!\nTest value1 = #{form.input1.value},  Test Value2 = #{form.input2.value}"
			view.show()

	addTestButton "Inline Form View", "Open", () ->
		addHolder().setView "Form", (view) ->
			view.addTextInput "input1", "Example Input 1"
			view.addTextInput "input2", "Example Input 2"
			view.addSubmit "submit", "", "Submit"
			view.setSubmitFunction (form) =>
				alert "Form Submitted Successfully!\nTest value1 = #{form.input1.value},  Test Value2 = #{form.input2.value}"
			view.show()
			view.setSize 1000, 99

	addTestButton "Form View Set Focus", "Open", () ->
		addHolder().setView "Form", (view) ->
			view.addTextInput "input1", "Example Input 1"
			view.addTextInput("input2", "Example Input 2").setFocus()
			view.addSubmit "submit", "", "Submit"
			view.setSubmitFunction (form) =>
				alert "Form Submitted Successfully!\nTest value1 = #{form.input1.value},  Test Value2 = #{form.input2.value}"
			view.show()

	addTestButton "Form View Validation", "Open", () ->
		addHolder().setView "Form", (view) ->
			view.addTextInput "input1", "Example Input 1", "Input Value1", {}, (val)->
				console.log "Validation function"
				if val is "123"
					return FormField.SUCCESS
				else if isNaN(val)
					@setWarningMsg "This value is not numeric..."
					return FormField.WARNING
				else
					@setErrorMsg "Value should be '123'..."
					return FormField.ERROR

			view.addTextInput "input2", "Example Input 2"
			view.addSubmit "submit", "", "Submit"
			view.setSubmitFunction (form) =>
				alert "Form Submitted Successfully!\nTest value1 = #{form.input1.value},  Test Value2 = #{form.input2.value}"
			view.show()

	addTestButton "Form on Popup", "Open", () ->
		doPopupView "Form", "Form on Popup", "form-popup1", 399, 300, (view) ->
			view.addTextInput "input1", "Example Input 1"
			view.addTextInput "input2", "Example Input 2"
			view.addSubmit "submit", "", "Submit"
			view.setSubmitFunction (form) =>
				alert "Form Submitted Successfully!\nTest value1 = #{form.input1.value},  Test Value2 = #{form.input2.value}"
			view.show()
		true
	
	addTestButton "Form on Popup with Many Fields", "Open", () ->
		doPopupView "Form", "Form on Popup with Many Fields", "form-popup2", 399, 300, (view) ->
			view.addTextInput "input1", "Example Input 1"
			view.addTextInput "input2", "Example Input 2"
			view.addTextInput "input3", "Example Input 3"
			view.addTextInput "input4", "Example Input 4"
			view.addTextInput "input5", "Example Input 5"
			view.addTextInput "input6", "Example Input 6"
			view.addTextInput "input7", "Example Input 7"
			view.addTextInput "input8", "Example Input 8"

			view.addSubmit "submit", "", "Submit"
			view.setSubmitFunction (form) =>
				alert "Form Submitted Successfully!\nTest value1 = #{form.input1.value},  Test Value2 = #{form.input2.value}"
			view.setScrollable()
			view.show()
		.then (popupView) ->
			console.log "PopupView: ", popupView
			popupView.getBody().setScrollable()
		true

	addTestButton "Form in Tab", "Open", () ->
		addHolder().setView "DynamicTabs", (tabs)->
			tabs.doAddViewTab("Form", "FormViewTab", (view)->
				view.addTextInput "input1", "Example Input 1"
				view.addTextInput "input2", "Example Input 2"
				view.addSubmit "submit", "Click this button to submit", "Submit"
				view.setSubmitFunction (form) =>
					alert "Form Submitted Successfully!\nTest value1 = #{form.input1.value},  Test Value2 = #{form.input2.value}"
				view.show()
			)
			tabs.addTab "EmptyTab", 'Another tab'	
		true

	addTestButton "Form with Pathfield - zipcode", "Open", ()=>
		addHolder().setView "Form", (view)->
			view.addTextInput "input1", "Text Input"
			view.addPathField "data-city", "zipcode", "03105", "city"
			view.addPathField "data-state", "zipcode", "03105", "state"
			view.addPathField "data-longitude", "zipcode", "03105", "lon"
			view.addSubmit "submit", "", "Submit"
			view.setSubmitFunction (form) =>
				alert "Form Submitted Successfully!\nTest value1 = #{form.input1.value}"
			view.show()
		true

	addTestButton "Form with Datafield - testData", "Open", ()=>
		addHolder().setView "Form", (view)->
			view.addTextInput "input1", "Text Input"
			view.addPathField "data-initialprice", "testData", "0011", "initialPrice", {"type": "calculation"}
			view.addPathField "data-currentprice", "testData", "0011", "currentPrice"
			view.addPathField "data-date", "testData", "0011", "date"
			view.addPathField "data-distance", "testData", "0011", "distance"
			view.addPathField "data-isnew", "testData", "isNew", "0011", {"type": "custom"}
			view.addPathField "data-sourcecode", "testData", "0011", "sourcecode"
			view.addPathField "data-memo", "testData", "0011", "memo"
			view.addSubmit "submit", "", "Submit"
			view.setSubmitFunction (form) =>
				alert "Form Submitted Successfully!\nTest value1 = #{form.input1.value}"
			view.show()
		true

	addTestButton "Change Data of Path - zipcode", "Change Data Fields", () =>
		DataMap.addData "zipcode", "03105", {
			city: "NewManchester"
			state: "NewState"
			lon: 12.34567
		}

	addTestButton "Form and Table with Pathfield - zipcode", "Open", ()=>
		viewExe = addHolder()
		viewExe.setView "Form", (view)->
			view.addTextInput "input1", "Text Input"
			view.addPathField "data-city", "zipcode", "03105", "city"
			view.addPathField "data-state", "zipcode", "03105", "state"
			view.addPathField "data-longitude", "zipcode", "03105", "lon"
			view.addSubmit "submit", "", "Submit"
			view.setSubmitFunction (form) =>
				alert "Form Submitted Successfully!\nTest value1 = #{form.input1.value}"
			view.show()
		true

	go()
