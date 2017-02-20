$ ->
	SplitData_V = {
		sizes: [40, 60]
		direction: "vertical"
		gutterSize: 6
		cursor: "row-resize"
		minSize: 20
	}
	SplitData_H = {
		sizes: [30, 70]
		direction: "horizontal"
		gutterSize: 6
		cursor: "col-resize"
	}


	addTestButton "Simple Vertical Splittable Widget", "Open", () ->
		addHolder("renderTest1")
		div = new WidgetTag "div", "testWidget"
		div.setAbsolute()
		div.appendTo("#renderTest1")
		div.setView "WidgetSplittable", (view)->
			view.setData SplitData_V
			view.setSize(900, 600)
			view.show()
		true
	
	addTestButton "Simple Horizontal Splittable Widget", "Open", () ->
		addHolder "renderTest1"
		div = new WidgetTag "div", "testWidget"
		div.setAbsolute()
		div.appendTo "#renderTest1"
		div.setView "WidgetSplittable", (view) ->
			view.setData SplitData_H
			view.setSize(900, 600)
			view.show()
		true

	addTestButton "Vertical & Horizontal Splittable Widgets", "Open", () ->
		addHolder("renderTest1")
		div_first_child = null
		div_second_child = null
		div_parent = new WidgetTag "div", "testWidget", "widget_Parent"
		div_parent.setAbsolute()

		div_parent.appendTo("#renderTest1")
		div_parent.setView "WidgetSplittable", (view)->
			view.setData SplitData_H
			view.setSize(900, 600)
			view.show()
			div_first_child = view.getWidget().getFirstChild()	
			div_second_child = view.getWidget().getSecondChild()

		setTimeout ->
			console.log "setTimeout"
			div_first_child.setView "WidgetSplittable", (view) ->
				view.setData SplitData_V
				view.show()
			div_second_child.setView "WidgetSplittable", (view) ->
				view.setData SplitData_V
				view.show()
		, 300
		true

	addTestButton "Popup Splittable Widget", "Open", () ->
		doPopupView "WidgetSplittable", "Splittable Widget", "popup_splittableWidget", 900, 600
		.then (view) ->
			view.setData SplitData_V
			view.show()
		true

	addTestButton "Tab Splittable Widget", "Open", () ->
		addHolder "renderTest1"
		tabs = new DynamicTabs("#renderTest1")
		tabs.doAddViewTab("WidgetSplittable", "Tab Splittable Widget", (view) ->
			view.setData SplitData_V
			view.setSize(0, 600)
			view.show()
		)
		tabs.addTab "Empty Tab", "<p style='font-size:xx-large;'>--- Another Tab ---</p>"
		true

	go()