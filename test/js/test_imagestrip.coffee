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
	addTestButton "Image Strip with few images", "Open", ()->
		addHolder("renderTest1")
		div = new WidgetTag "div", "testWidget"
		div.appendTo("#renderTest1")
		div.setView "ImageStrip", (view)->
			view.init()
			view.addImage newImage1
			view.addImage newImage2
			view.addImage newImage3
			view.addImage newImage4
			view.addImage newImage5
			view.addImage newImage6
			view.render()
		true
	addTestButton "Image Strip with 20 images", "Open", ()->
		addHolder("renderTest1")
		div = new WidgetTag "div", "testWidget"
		div.appendTo("#renderTest1")
		div.setView "ImageStrip", (view)->
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
			view.render()
		true

	##|
    ##|  popup window Image View
    ##|
	addTestButton "Image Strip in popup", "Open", ()->
		doPopupView 'ImageStrip','Image Strip', 'imagestrip_popup', 1000, 800
		.then (view) ->
			view.setTitle("Test Title")
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
			view.render()
		true

	##|
	addTestButton "ImageStrip in tab", "Open", ()->
		addHolder("renderTest1")
		tabs = new DynamicTabs('#renderTest1')
		tabs.doAddViewTab("ImageStrip", "ImageStripTab", (view)->
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
			view.render()
		)
		tabs.addTab "EmptyTab", '<h2>Another tab</h2>'
		true

	go()