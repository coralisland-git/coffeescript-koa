$ ->
	SplitData_Simple = {
		sizes: [100, 200]
		direction: "vertical"
	}
	addTestButton "Simple Splittable Widget", "Open", () ->
		addHolder("renderTest1")
		div = new WidgetTag "div", "testWidget"
		div.appendTo("#renderTest1")
		div.setView "WidgetSplittable", (view)->
			view.setData SplitData_Simple
			view.show()
		true

	go()