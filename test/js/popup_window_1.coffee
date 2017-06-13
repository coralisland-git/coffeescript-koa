newImage1 = new Image()
newImage1.src = "./js/test_Data/images/1.jpg"
newImage2 = new Image()
newImage2.src = "./js/test_Data/images/2.jpg"
newImage3 = new Image()
newImage3.src = "./js/test_Data/images/3.jpg"
newImage4 = new Image()
newImage4.src = "./js/test_Data/images/4.jpg"
newImage5 = new Image()
newImage5.src = "./js/test_Data/images/5.jpg"
newImage6 = new Image()
newImage6.src = "./js/test_Data/images/6.jpg"
newImage7 = new Image()
newImage7.src = "./js/test_Data/images/7.jpg"
newImage8 = new Image()
newImage8.src = "./js/test_Data/images/8.jpg"
newImage9 = new Image()
newImage9.src = "./js/test_Data/images/9.jpg"
newImage10 = new Image()
newImage10.src = "./js/test_Data/images/10.jpg"
newImage11 = new Image()
newImage11.src = "https://www.e-architect.co.uk/images/jpgs/concept/large-span-translucent-buildings-s010313.jpg"

$ ->

	$("body").append '''
	    <style type="text/css">
	    .scrollcontent {
	        height : 100% !important;
	    }
	    </style>
	'''
	##|
	##|  Load the zipcodes JSON file.
	##|  This will insert the zipcodes into the global data map.
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

	##|
	##|  This is just for diagnostics,  you don't need to verify the data map is
	##|  loaded normally.  The data types should be loaded upon startup.
	addTest "Confirm Zipcodes datatype loaded", () ->
		dm = DataMap.getDataMap()
		if !dm? then return false

		zipcodes = dm.types["zipcode"]
		if !zipcodes? then return false
		if !zipcodes.col["code"]? then return false

		true

	addTestButton "Hello World", "Open", (e)->

		popup = new PopupWindow "Test Window", 50, 50
		popup.windowScroll.append $ "<div> Hello World </div>"
		return 1

	addTestButton "Scroll Test", "Open", (e)->

		popup = new PopupWindow "Test Window", 50, 50

		str = ""
		for x in [0..100]
			str += "Testing #{x}<br>"

		popup.windowScroll.html str
		return 1

	addTestButton "Toolbar Test", "Open", (e)->

		popup = new PopupWindow "Test Window", 500, 400

		navButton = new NavButton("Test", "toolbar-btn navbar-btn", {
			"data-click": "sampleAttribute"
		});

		navButton2 = new NavButton "Dropdown Test &#x25BC;", "toolbar-btn navbar-btn"
		navButton2.onClick = (e)=>

			menu = new PopupMenu "Test Window", e
			menu.setMultiColumn 4, 200

			list = "Apple Banana Cherry Grapefruit Grape Lemon Lime Melon Orange Peach Pear
				Pineapple Plum Strawberry Tangerine Watermelon Carrot Black Blue Brown
				Gray Green Pink Purple Red White Yellow Bull Cow Calf Cat Chicken Duck Goat
				Goose Horse Lamb Pig Shep Turkey Monkey Bird Ford Chevy Honda Circle".split ' '

			for name in list

				menu.addItem name, (e, info)=>
					console.log "Selected e=",e, "info=", info
				, name

		popup.addToolbar [ navButton, navButton2 ]

		str = ""
		for x in [0..100]
			str += "Testing #{x}<br>"

		popup.windowScroll.html str
		return 1

	addTestButton "Saved Location and size Test", "Open", (e) ->

		popup = new PopupWindow "Test Window",50,50,
			tableName: "testTable"
			w: 400
			h: 500
		popup.windowScroll.append $ "<div> Hello World </div>"

	addTestButton "Popup Modal", "Open", (e) ->

		popup = new PopupWindow "Test Window"
		popup.modal(500, 400)
		popup.html "Testing"

	addTestButton "Hide Popup with keyValue Test", "Open", (e) ->

		popup = new PopupWindow "Test Window",50,50,
			tableName: "zipcodes"
			keyValue: 28117
			windowName: "ZipcodeDetailWindow"
			w: 600
			h: 200
		popup.windowScroll.append $ "<div> Hello World </div>"

	addTestButton "PopupViewOnce 1 Table", "Open", (e) ->
		doPopupViewOnce "Table", "Test1", "test1_table", 600, 400, "Tab1", (view, tabText) ->
			view.loadTable 'zipcode'

	addTestButton "PopupViewOnce 1 Table (Empty)", "Open", (e) ->
		doPopupViewOnce "Table", "Test1", "test1_table", 600, 400, "Tab1", (view, tabText) ->
			view.loadTable 'zipcode'
		doPopupViewOnce "Table", "Test1", "test2_table", 600, 400, "Tab with empty", (view, tabText) ->
			# view.loadTable 'zipcode'
			view.loadTable "totally_empty_table"

	addTestButton "PopupViewOnce 1 ImageStrip", "Open", (e) ->
		doPopupViewOnce "ImageStrip", "Test1", "test1_imagestrip", 600, 400, "Tab2", (view, tabText) ->
			view.init()
			view.addImage newImage1
			view.addImage newImage2
			view.addImage newImage3
			view.addImage newImage4
			view.addImage newImage5
			view.addImage newImage6
			view.addImage newImage7
			view.addImage newImage8
			view.addImage newImage9
			view.addImage newImage10
			view.addImage newImage11
			view.render()

	addTestButton "PopupViewOnce 2 Form", "Open", (e) ->	
		doPopupViewOnce "Form", "Test2", "test2_form-popup", 399, 300, "Tab1", (view, tabText) ->
			view.init()
			view.getForm().addTextInput "input1", "Example Input 1"
			view.getForm().addTextInput "input2", "Example Input 2"
			view.getForm().addSubmit "submit", "Click this button to submit", "Submit"
			view.getForm().onSubmit = (form) =>
				alert "Form Submitted Successfully!\nTest value1 = #{form.input1},  Test Value2 = #{form.input2}"
			view.show()

	addTestButton "PopupViewOnce 2 Table", "Open", (e) ->
		doPopupViewOnce "Table", "Test2", "test2_table", 399, 300, "Tab2", (view, tabText) ->
			view.loadTable 'zipcode'


	go()
