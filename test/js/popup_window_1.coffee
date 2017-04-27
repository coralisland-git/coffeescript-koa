$ ->

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

	addTestButton "PopupViewOnce", "Open", (e) ->
		doPopupViewOnce "Table", "Test1", "", 900, 600, "Tab1"

	go()
