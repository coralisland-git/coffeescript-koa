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

	go()