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

	addTestButton "Popup Splittable-Widget : Text/Tabs(Table & ImageStrip)", "Open", () ->
		doPopupView "Splittable", "Splittable Widget", "popup_splittableWidget2", 900, 600, (view)->

			view.getFirst().html '<p style="font-size:30px;">Dummy Text</p>'

			view.getSecond().setView "DynamicTabs", (tabsView)->
				newPromise () ->
					yield loadZipcodes()

					tabsView.doAddViewTab "Table", "Table", (view) ->
						view.loadTable "zipcode"

					tabsView.doAddViewTab "ImageStrip", "Images", (view) ->
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

	addTestButton "Simple Vertical 50/50", "Open", () ->
		addHolder("")
		.setView "Splittable", (splitter)->
			splitter.setPercent(50)
			splitter.getFirst().html "Left side should be 50%"
			splitter.getSecond().html "Right side should be 50%"

	addTestButton "Use LocalStrage by setting configName", "Open", () ->
		addHolder("")
		.setView "Splittable", (splitter)->
			splitter.setPercent 50
			splitter.setConfigName "test1"
			splitter.getFirst().setView "TestShowSize"
			splitter.getSecond().setView "TestShowSize"

	addTestButton "Simple Vertical 50/50 - Left Min Size", "Open", () ->
		addHolder("")
		.setView "Splittable", (splitter)->
			splitter.setPercent(50)
			splitter.getFirst().html "Left side should be 50%, min 200px"
			splitter.getSecond().html "Right side should be 50%"
			splitter.getFirst().setMinWidth(200)

	addTestButton "Simple Horizontal 50/50", "Open", () ->
		addHolder("")
		.setView "Splittable", (splitter)->
			splitter.setHorizontal()
			splitter.setPercent(50)
			splitter.getFirst().html "Top should be 50%"
			splitter.getSecond().html "Bottom should be 50%"

	addTestButton "Simple Horizontal 50/50 with Events", "Open", () ->
		addHolder("")
		.setView "Splittable", (splitter)->
			splitter.setHorizontal()
			splitter.setPercent(50)
			splitter.getFirst().html "Top should be 50%"
			splitter.getSecond().html "Bottom should be 50%"

			superResize = splitter.onResize
			splitter.onResize = (w, h)->
				superResize(w,h)
				PercentTop = Math.ceil(splitter.getPercent())
				PercentBot = 100 - PercentTop
				splitter.getFirst().html "Top should be #{PercentTop}% or #{splitter.size1} px"
				splitter.getSecond().html "Bottom should be #{PercentBot}% or #{splitter.size2} px"

	addTestButton "Vertical & Horizontal Splittable Widgets", "Open", () ->
		addHolder("")
		.setView "Splittable", (splitter)->
			splitter.setHorizontal()
			splitter.setPercent(40)
			splitter.getFirst().html "Top should be 40%"
			splitter.getSecond().setView "Splittable", (splitter2)->
				splitter2.setPercent(40)
				splitter2.getFirst().html "Bottom Left side should be 40%"
				splitter2.getSecond().html "Bottom Right side should be 60%"

	addTestButton "Tab Splittable Widget", "Open", () ->
		addHolder()
		.setView "DynamicTabs", (tabs)->
			tabs.doAddViewTab "Splittable", "Tab Splittable Widget", (splitter) ->
				splitter.setPercent(25)
				splitter.getFirst().html "Left side should be 25%"
				splitter.getSecond().html "Right side should be 75%"

			tabs.addTab "Empty Tab", "<p style='font-size:xx-large;'>--- Another Tab ---</p>"

		true

	addTestButton "Splitter with Tables", "Open", () ->

		addHolder("")
		.setView "Splittable", (splitter)->
			splitter.setHorizontal()
			splitter.setPercent(40)

			loadZipcodes().then ->
				splitter.getFirst().setView "Table", (viewTable1)->
					viewTable1.loadTable "zipcode"

				splitter.getSecond().setView "Table", (viewTable2)->
					viewTable2.loadTable "zipcode"
		true


	addTestButton "Table & TableDetailed in Splittable", "Open", () ->

		doPopupView "Splittable", "Splittable Widget", "popup_splittableWidget3", 1500, 800, (view)->
			view.setPercent(70)
			view.getSecond().setMinWidth(300)

			loadZipcodes().then ->

				view.getFirst().setView "Table", (viewTable1)->
					viewTable1.loadTable "zipcode"

				view.getSecond().setView "TableDetail", (viewTable2)->
					viewTable2.loadTable "zipcode"

	go()