$ ->


	addTestButton "Table Detail View", "Open", ()->
		addHolder("renderTest1");
		$("#renderTest1").width 250
		table = new TableViewDetailed $("#renderTest1")
		table.addTable "zipcode"
		table.render('00544')

		true

	addTestButton "Table Detail View for GeoCode", "Open", ()->
		addHolder("renderTest1");
		$("#renderTest1").width 250

		table = new TableViewDetailed $("#renderTest1")
		table.addTable "geoset"
		table.render('1')

		true

	addTestButton "Table Detail View in popup", "Open", ()->
		table = new TableViewDetailed $("#renderTest1")
		table.addTable "geoset"
		new PopupTable table, "geosetrow1", '1'

		true

	go()
