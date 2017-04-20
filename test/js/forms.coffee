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
	
	addTestButton "Form  on Popup with Many Fields", "Open", () ->
		doPopupView "Form", "Form-Popup", "form-popup", 399, 300
		.then (view) ->
			view.init()
			view.getForm().addTextInput "input1", "Example Input 1"
			view.getForm().addTextInput "input2", "Example Input 2"
			view.getForm().addTextInput "input3", "Example Input 3"
			view.getForm().addTextInput "input4", "Example Input 4"
			view.getForm().addTextInput "input5", "Example Input 5"
			view.getForm().addTextInput "input6", "Example Input 6"
			view.getForm().addTextInput "input7", "Example Input 7"
			view.getForm().addTextInput "input8", "Example Input 8"
			view.getForm().addTextInput "input9", "Example Input 9"
			view.getForm().addTextInput "input10", "Example Input 10"
			view.getForm().addTextInput "input11", "Example Input 11"
			view.getForm().addTextInput "input12", "Example Input 12"
			view.getForm().addTextInput "input13", "Example Input 13"
			view.getForm().addTextInput "input14", "Example Input 14"
			view.getForm().addTextInput "input15", "Example Input 15"
			view.getForm().addTextInput "input16", "Example Input 16"
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
			view.getForm().addPathField "data-initialprice", "testData", "initialPrice", {"type": "calculation"}
			view.getForm().addPathField "data-currentprice", "testData", "currentPrice"
			view.getForm().addPathField "data-date", "testData", "date"
			view.getForm().addPathField "data-distance", "testData", "distance"
			view.getForm().addPathField "data-isnew", "testData", "isNew", {"type": "custom"}
			view.getForm().addPathField "data-sourcecode", "testData", "sourcecode"
			view.getForm().addPathField "data-memo", "testData", "memo"
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

	addTestButton "Form and Table with Pathfield - zipcode", "Open", ()=>
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

		addHolder "renderTest2"
		wdt_id = new WidgetTag "td", null, "wdt_td_id"
		wdt_city = new WidgetTag "td", null, "wdt_td_city"
		wdt_state = new WidgetTag "td", null, "wdt_td_state"
		wdt_lon = new WidgetTag "td", null,"wdt_td_lon"

		$("#renderTest2").append($ "<br><table class='test_table'><caption>This is table of data fields same as in form above</caption></table>")
		$(".test_table").append wdt_id.getTag()
		$(".test_table").append wdt_city.getTag()
		$(".test_table").append wdt_state.getTag()
		$(".test_table").append wdt_lon.getTag()

		wdt_id.bindToPath "zipcode", "03105", "id"
		wdt_city.bindToPath "zipcode", "03105", "city"
		wdt_state.bindToPath "zipcode", "03105", "state"
		wdt_lon.bindToPath "zipcode", "03105", "lon"
		true

	go()
	