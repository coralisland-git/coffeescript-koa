$ ->
	SplitData_V = {
		sizes: [40, 60]
		direction: "vertical"
		gutterSize: 8
		cursor: "row-resize"
	}
	SplitData_H = {
		sizes: [30, 70]
		direction: "horizontal"
		gutterSize: 8
		cursor: "col-resize"
	}
	addTestButton "Simple Vertical Splittable Widget", "Open", () ->
		addHolder("renderTest1")
		div = new WidgetTag "div", "testWidget"
		div.appendTo("#renderTest1")
		div.setView "WidgetSplittable", (view)->
			view.setData SplitData_V
			view.show()
		true
	
	addTestButton "Simple Horizontal Splittable Widget", "Open", () ->
		addHolder "renderTest1"
		div = new WidgetTag "div", "testWidget"
		div.appendTo "#renderTest1"
		div.setView "WidgetSplittable", (view) ->
			view.setData SplitData_H
			view.show()
		true

	addTestButton "Vertical & Horizontal Splittable Widgets", "Open", () ->
		addHolder("renderTest1")
		widget_Parent = {}
		div_parent = new WidgetTag "div", "testWidget", "widget_Parent"

		div_parent.appendTo("#renderTest1")
		div_parent.setView "WidgetSplittable", (view)->
			view.setData SplitData_H
			view.show()
			Object.assign widget_Parent, view
			
		setTimeout ->
			console.log "setTimeout"
			widget_Parent.getWidget().getFirstChild().setView "WidgetSplittable", (view) ->
				view.setData SplitData_V
				view.show()
		, 10000
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
			view.show()
		)
		tabs.addTab "Empty Tab", "<p style='font-size:xx-large;'>--- Another Tab ---</p>"
		true

	go()