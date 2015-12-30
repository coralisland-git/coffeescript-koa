$ ->

	startTest = (data) ->

		##|
		##|  Data is a JSON record that we want to work with (test_data/DataRawRec1.json)
		##|  TableConfigTest is the column collection loaded at compile time

		dtc = new DataTypeCollection "TestConfig", TableConfigTest
		console.log "DTC=", dtc.colList
		builder = new DataMapperBuilder data, dtc, "#testCase"

		src = '''
			{"GF20030226223929852543000000":{"mapType":"copy","mapSource":"GF20030226223929852543000000","mapDest":"property_type","mapName":"Property Type"}}
		'''

		builder.deserialize src

	$.ajax
		url: '/test/js/test_data/DataRawRec1.json'

	.done (data) ->
		startTest data

	.fail (e) ->
		console.log "Failed to get data:", e



