$ ->

	$("body").append '''
	    <style type="text/css">
	
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

	addTestButton "Form with Pathfield - zipcode", "Open", ()=>
		addHolder "renderTest1"
		div = new WidgetTag "div", "testWidget"
		div.appendTo "#renderTest1"
		div.setView "Form", (view)->
			view.init()
			view.getForm().addTextInput "input1", "Text Input"
			view.getForm().addPathField "data-city", "zipcode", "city"
			view.getForm().addPathField "data-state", "zipcode", "state"
			view.getForm().addPathField "data-longitude", "zipcode", "lon"
			view.getForm().addSubmit "submit", "Click this button to submit", "Submit"
			view.getForm().onSubmit = (form) =>
				alert "Form Submitted Successfully!\nTest value1 = #{form.input1}"
			view.show()
			view.getForm().setPath "zipcode", "03105"
		true

	addTestButton "Form with Datafield - testData", "Open", ()=>
		addHolder "renderTest1"
		div = new WidgetTag "div", "testWidget"
		div.appendTo "#renderTest1"
		div.setView "Form", (view)->
			view.init()
			view.getForm().addTextInput "input1", "Text Input"
			view.getForm().addPathField "data-initialprice", "testData", "initialPrice"
			view.getForm().addPathField "data-currentprice", "testData", "currentPrice"
			view.getForm().addPathField "data-date", "testData", "date"
			view.getForm().addPathField "data-distance", "testData", "distance"
			view.getForm().addPathField "data-isnew", "testData", "isNew"
			view.getForm().addSubmit "submit", "Click this button to submit", "Submit"
			view.getForm().onSubmit = (form) =>
				alert "Form Submitted Successfully!\nTest value1 = #{form.input1}"
			view.show()
			view.getForm().setPath "testData", "0011"
		true

	addTestButton "Change Data of Path - zipcode", "Change Data Fields", () =>
		DataMap.addData "zipcode", "03105", {
			city: "NewManchester"
			state: "NewState"
			lon: 12.34567
		}

	go()
	