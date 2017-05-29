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

$ ->

	$("body").append '''
	    <style type="text/css">
	    .scrollcontent {
	        height : 100% !important;
	    }
	    </style>
	'''
	
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
		doPopupView "WidgetSplittable", "Splittable Widget", "popup_splittableWidget1", 900, 600
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

	addTestButton "Popup Splittable-Widget : Text/Tabs(Table & ImageStrip)", "Open", () ->
		div_first_child = null
		div_second_child = null
		doPopupView "WidgetSplittable", "Splittable Widget", "popup_splittableWidget2", 900, 600
		.then (view) ->
			view.setData SplitData_V
			view.show()
			div_first_child = view.getWidget().getFirstChild()	
			div_second_child = view.getWidget().getSecondChild()
			div_first_child.html '<p style="font-size:30px;">Dummy Text</p>'
			newPromise () ->
				yield loadZipcodes()
				tabs = new DynamicTabs(div_second_child)
				tabs.doAddViewTab "Table", "Table", (view, tabText) ->
					view.loadTable "zipcode"
				tabs.doAddViewTab "ImageStrip", "Images", (view, tabText) ->
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
					view.addImage newImage1.src
					view.addImage newImage2.src
					view.addImage newImage3.src
					view.addImage newImage4.src
					view.addImage newImage5.src
					view.addImage newImage6.src
					view.addImage newImage7.src
					view.addImage newImage8.src
					view.addImage newImage9.src
					view.addImage newImage10.src
					view.setSize 0, 400
					view.render()
			.then ()->
				console.log "Done."

		true

	go()