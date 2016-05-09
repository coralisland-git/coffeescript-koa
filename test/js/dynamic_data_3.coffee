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

	if true
		console.log "Adding tests"

		io = new DataMapEngine "test"

		addTest "Init DataEngineIO", ()->

			doc = io.get "/people/1"
			if !doc?
				return "Valid"
			else
				console.log doc
				return "Invalid"

		addTest "Set DataEngineIO", ()->

			doc = io.get "/people/2", true
			doc.name = 'Brian'
			io.set "/people/2", doc
			if doc? and doc.name? and doc.name == "Brian"
				return true

			return "Invalid"

		addTest "Get Again DataEngineIO", ()->

			doc = io.get "/people/2"
			##|  should be set from previous test
			if !doc? or !doc.name? or doc.name != "Brian"
				return "Invalid doc 1"

			##|  should not be set
			if doc? and doc.address?
				return "Invalid: address should not yet be set"

			doc.address =
				street: "Montibello dr"
				number: 293

			io.set "/people/2", doc

			doc2 = io.get "/people/2"
			if !doc2? or !doc2.address? or doc2.address.number != 293
				console.log "Invalid doc=", doc2
				return "Invalid doc2"

			console.log "Doc2=", doc2
			return true

		addTest "Get Sub Path", ()->

			doc = io.get "/people/2/address"
			if !doc? or !doc.number? or doc.number != 293
				console.log "Invalid doc=", doc
				return "Invalid sub path get"

			##|
			##|  Set the number from 293 to 111 in the sub path
			# doc.number = 111
			doc3 =
				happy: 12345
				number: 111
			io.set "/people/2/address", doc3

			##|
			##|  Get the document entirely
			doc4 = io.get "/people/2"
			if !doc4? or !doc4.address? or !doc4.address.number?
				return "Missing doc4"

			if !doc4.address.happy or doc4.address.happy != 12345
				return "Missing doc4 happy"

			if doc4.address.number != 111
				return "Doc4 wrong number"

			return true

		addTest "Get Data from Map", () ->

			console.log "---------------------------------------------------------------------------------------"
			console.log "---------------------------------------------------------------------------------------"

			DataMap.addData "people", 2,
				name: "Test2"
				age: 100

			currentValue = DataMap.getDataField "people", 2, "name"
			if currentValue == "Test2"
				return true

			console.log "Invalid value is ", currentValue
			return "Failed, got #{currentValue}"

		# ##|
		# ##|  Load the zipcodes JSON file.
		# ##|  This will insert the zipcodes into the global data map.
		# addTest "Loading Zipcodes", () ->

		# 	new Promise (resolve, reject) ->
		# 		ds  = new DataSet "zipcode"
		# 		ds.setAjaxSource "/js/test_data/zipcodes.json", "data", "code"
		# 		ds.doLoadData()
		# 		.then (dsObject)->
		# 			resolve(true)
		# 		.catch (e) ->
		# 			console.log "Error loading zipcode data: ", e
		# 			resolve(false)

		# ##|
		# ##|  Verify the "getColumnsFromTable" returns correctly
		# ##|
		# addTest "Get Columns - All", () ->

		# 	columns = DataMap.getColumnsFromTable "zipcode"
		# 	counter = 0
		# 	for col in columns
		# 		counter++
		# 		console.log col

		# 	return counter == 7

		# addTest "Get Data - No Filter", () ->

		# 	data = DataMap.getValuesFromTable "zipcode"
		# 	counter = data.length
		# 	return counter == 854

		# addTest "Get Data - Filter", () ->

		# 	data = DataMap.getValuesFromTable "zipcode", (obj) ->
		# 		return obj.county == "MIDDLESEX"

		# 	counter = data.length
		# 	return counter == 116

		go()


	#