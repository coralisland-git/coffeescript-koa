$ ->

	$("body").append '''
		<style type="text/css">
		.data {
			width  : 300px;
			border : 1px solid #bbbbdd;
			color  : #309030
		}
		</style>
	'''

	##|
	##|  Load the zipcodes JSON file.
	##|  This will insert the zipcodes into the global data map.
	addTest "Loading Zipcodes", () ->

		new Promise (resolve, reject) ->
			ds  = new DataSet "zipcode"
			ds.setAjaxSource "/js/test_data/zipcodes.json", "data", "code"
			ds.doLoadData()
			.then (dsObject)->
				resolve(true)
			.catch (e) ->
				console.log "Error loading zipcode data: ", e
				resolve(false)

	##|
	##|  Verify the "getColumnsFromTable" returns correctly
	##|
	addTest "Get Columns - All", () ->

		columns = DataMap.getColumnsFromTable "zipcode"
		counter = 0
		for col in columns
			counter++
			console.log col

		return counter == 7

	addTest "Get Data - No Filter", () ->

		data = DataMap.getValuesFromTable "zipcode"
		counter = data.length
		return counter == 854

	addTest "Get Data - Filter", () ->

		data = DataMap.getValuesFromTable "zipcode", (obj) ->
			return obj.county == "MIDDLESEX"

		counter = data.length
		return counter == 116

	go()


#