ImageData =
	{
		'src':"./js/test_Data/images/1.jpg"
	}

$ ->
	addTestButton "Image Strip", "Open", ()->
		div = addHolderWidget('renderTest1')
		div.setView "ImageStrip", (view)->
			view.init()
			for i in [0..5]
				newImage1 = new Image()
				newImage1.src = "./js/test_Data/images/1.jpg"
				newImage2 = new Image()
				newImage2.src = "./js/test_Data/images/2.jpg"
				view.addImage newImage1
				view.addImage newImage2
			view.show()
		true
	go()