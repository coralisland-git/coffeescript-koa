$ ->
	
	##|
	##|  Load the zipcodes JSON file.
	##|  This will insert the zipcodes into the global data map.
	addTest "Loading Zipcodes", () ->
		new Promise (resolve, reject) ->
			ds = new DataSet "zipcode"
			ds.setAjaxSource "/js/test_data/zipcodes.json", "data", "code"
			ds.doLoadData()
			.then (dsObject)->
				resolve(true)
			.catch (e) ->
				console.log "Error loading zipcode data: ", e
				resolve(false)

##|
##|  This is just for diagnostics,  you don't need to verify the data map is
##|  loaded normally.  The data types should be loaded upon startup.
	addTest "Confirm Zipcodes datatype loaded", () ->
		dm = DataMap.getDataMap()
		if !dm? then return false

		zipcodes = dm.types["zipcode"]
		if !zipcodes? then return false
		if !zipcodes.col["code"]? then return false

		true

	addTest "add single row in geoset table", () ->
		## add the sample data to geoset table
		DataMap.addData "geoset", "1",
				id: 1
				lastModified: '2016-04-20 10:10:00'
				title: 'sample Title'
				county: 'BERKSHIRE'
				dataset_type: 'Parcel'
				description: 'sample description'
				metro_area: 'Charlotte'
				source_url: 'http://maps.co.mecklenburg.nc.us/opendata/Parcel_TaxData.zip'
				total_points: 382725
				bbox: [
					'1449197.0931383073'
					'390084.8933570981'
					'1617626.7021882534'
					'533989.131004706'
				]

	##|
	##|  Load the zipcodes JSON file.
	##|  This will insert the zipcodes into the global data map.
	addTest "Loading Zipcodes", () ->
		new Promise (resolve, reject) ->
			ds = new DataSet "zipcode"
			ds.setAjaxSource "/js/test_data/zipcodes.json", "data", "code"
			ds.doLoadData()
			.then (dsObject)->
				resolve(true)
			.catch (e) ->
				console.log "Error loading zipcode data: ", e
				resolve(false)


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
