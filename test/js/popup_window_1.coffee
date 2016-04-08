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

	addTestButton "Saved Location and size Test", "Open", (e) ->

		popup = new PopupWindow "Test Window",50,50,
			tableName: "testTable"
			w: 400
			h: 500
		popup.windowScroll.append $ "<div> Hello World </div>"

	addTestButton "Hide Popup with keyValue Test", "Open", (e) ->

		popup = new PopupWindow "Test Window",50,50,
			tableName: "zipcodes"
			keyValue: 28117
			windowName: "ZipcodeDetailWindow"
			w: 600
			h: 200
		popup.windowScroll.append $ "<div> Hello World </div>"
	go()
