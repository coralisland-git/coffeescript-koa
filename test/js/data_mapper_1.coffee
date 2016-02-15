$ ->

	demoMode = 0

	startTest = (data) ->

			##|
			##|  Data is a JSON record that we want to work with (test_data/DataRawRec1.json)
			##|  TableConfigTest is the column collection loaded at compile time

			dtc = new DataTypeCollection "TestConfig", TableConfigProperty
			builder = new DataMapperBuilder data, dtc, "#testCase"

			if demoMode == 0
				##|
				##| No data as the default
				console.log "Starting without data"
				src = ''

			else if demoMode == 1

				console.log "Starting with some data"
				src = '''
					{"GF20030226223929852543000000":{"mapType":"copy","mapSource":"GF20030226223929852543000000","mapDest":"property_type","mapName":"Property Type","transform":[{"type":"transform","pattern":"asdf","dest":"asdfadsf"}]}}
				'''

			builder.deserialize src

	startDemo = (dm)->

		demoMode = dm
		$("#testCase").html ""

		$.ajax
			url: '/js/test_data/DataRawRec1.json'

		.done (data) ->
			startTest data

		.fail (e) ->
			console.log "Failed to get data:", e


	addTestButton "Open without save data", "Open", ()->
		startDemo(0)

	addTestButton "Open with some save data", "Open", ()->
		startDemo(1)

	go()



