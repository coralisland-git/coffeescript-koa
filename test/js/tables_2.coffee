$ ->

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

	##|
	##|  Load the zipcodes JSON file.
	##|  This will insert the zipcodes into the global data map.
	addTest "Loading Zipcodes", () ->

		new Promise (resolve, reject) ->
			ds  = new DataSet "zipcode"
			ds.setAjaxSource "/js/test_Data/zipcodes.json", "data", "code"
			ds.doLoadData()
			.then (dsObject)->
				resolve(true)
			.catch (e) ->
				console.log "Error loading zipcode data: ", e
				resolve(false)


	addTestButton "context menu with sorting in header according to DataType", "Open", ()->
		addHolder("renderTest1")
		table = new TableView $("#renderTest1")
		table.addTable "zipcode"
		table.real_render()
		#table.updateRowData()
		true

	addTestButton "inline sorting with icon in header according to DataType", "Open", ()->
		addHolder("renderTest1");
		table = new TableView $("#renderTest1")
		table.addTable "zipcode"
		table.real_render()
		$('#renderTest1').prepend "<input type='button' id='sortByCityDSC' class='btn btn-info' style='margin-bottom:15px; margin-left:30px;' value='Sort By City DSC' />"
		$('#sortByCityDSC').on 'click', ()->
			table.sortByColumn('city','DSC')
		$('#renderTest1').prepend "<input type='button' id='sortByCityTOG' class='btn btn-info' style='margin-bottom:15px; margin-left:30px;' value='Sort By City Toggle' />"
		$('#sortByCityTOG').on 'click', ()->
			table.sortByColumn('city','Random')
		$('#renderTest1').prepend "<input type='button' id='sortByCityASC' class='btn btn-info' style='margin-bottom:15px;' value='Sort By City ASC' />"
		$('#sortByCityASC').on 'click', ()->
			table.sortByColumn('city','ASC')
		true

	addTestButton "auto hide columns from left on resize", "Open", ()->
		DataMap.setDataTypes "zipcode", [
			name    : "Custom-1"
			source  : "city"
			visible : true
			type    : "text"
			width   : 300
			render  : (val, path) ->
				return "250px"
		]
		DataMap.setDataTypes "zipcode", [
			name    : "hidden column1"
			source  : "code2"
			visible : true
			type    : "text"
			render  : (val, path) ->
				return "can hide"
		]
		DataMap.setDataTypes "zipcode", [
			name    : "Hidden Column2"
			source  : "code3"
			visible : true
			type    : "text"
			render  : (val, path) ->
				return "hide"
		]
		addHolder("renderTest1");
		table = new TableView $("#renderTest1")
		table.addTable "zipcode"
		table.real_render()
		#width can be dynamic as parameter | default = 32
		#table.setAutoHideColumn()
		true

	addTestButton "simpleobject data type test", "Open", ()->
		##| set the address as object in data map, to manipulate address field as simple object
		for key,obj of DataMap.getDataMap().engine.export("zipcode")
			obj.address = {city:obj.city,state:obj.state,county:obj.county}

		DataMap.setDataTypes "zipcode", [
			name    : "Address"
			source  : "address"
			visible : true
			type    : "simpleobject"
			width   : 200,
			options:
				compile: "{{city}}, {{state}}, {{county}}"
		]
		addHolder("renderTest1");
		table = new TableView $("#renderTest1")
		table.addTable "zipcode"
		table.real_render()
		true

	addTestButton "dynamic add/remove row test case", "Open", ()->
		addHolder("renderTest1");
		table = new TableView $("#renderTest1")
		table.addTable "zipcode"
		table.render()
		table.updateRowData()
		_btnText = "&lt;input type='button' id='deleteFirstRow' class='btn btn-danger' style='margin-bottom:15px;' value='Delete First Row' /&gt;"
		_btnText = _btnText.replace('&lt;','<').replace('&gt;','>')
		$('#renderTest1').prepend _btnText
		_btnText = "&lt;input type='button' id='addNewRow' class='btn btn-success' style='margin-bottom:15px;' value='Add New Row' /&gt;"
		_btnText = _btnText.replace('&lt;','<').replace('&gt;','>')
		$('#renderTest1').prepend _btnText
		$('#addNewRow').on 'click', () ->
			##| manipulate data
			_randomKey = Math.floor Math.random()*90000 + 10000
			#_randomData = DataMap.getDataMap().data['zipcode']["0#{Math.floor Math.random() * (1344 - 1337 + 1) + 1337}"]
			_randomData = DataMap.getDataForKey "zipcode", "0#{Math.floor Math.random() * (1344 - 1337 + 1) + 1337}"
			if _randomData
				_randomData['code'] = _randomKey
			##| add data
			DataMap.addData 'zipcode', _randomKey, _randomData
			##| applyFilters to update new Data
			table.applyFilters()
			table.updateRowData()
		$('#deleteFirstRow').on 'click', () ->
			##| get first row key from table to pass as arg in function
			_key = $('#renderTest1 .table-wrapper .tableRow').first().find('.cell').first().text()
			##| function to delete the data from dataMap and from screen
			DataMap.deleteDataByKey 'zipcode', _key
			console.log "First Row was deleted"
			table.updateRowData()
		true

	addTestButton "editable popup on click", "Open", ()->
		addHolder("renderTest1");
		table = new TableView $("#renderTest1")
		table.addTable "zipcode"
		table.render()
		table.updateRowData()
		$('#renderTest1').prepend "<input type='button' id='createNew' class='btn btn-info' style='margin-bottom:15px;' value='Create New' />"
		$('#createNew').on 'click', ()->
			p = new PopupForm('zipcode','code')
			p.onCreateNew = (tableName, data) ->
				console.log tableName,data
				##| apply filter or sorting to update the newly create row
				setTimeout () ->
					table.applyFilters()
				,1
				true

		table.rowCallback = (data,e) ->
			if data.id
				new PopupForm('zipcode', 'code', data.id)
		true

	addTestButton "editable popup on click with custom columns", "Open", ()->
		addHolder("renderTest1");
		table = new TableView $("#renderTest1")
		table.addTable "zipcode"
		table.render()
		table.updateRowData()
		_columns = []
		_columns.push
			name       : 'State'
			source     : 'state'
			type       : 'text'
			required   : true
		_columns.push
			name       : 'County'
			source     : 'county'
			type       : 'text'
			required   : true
		table.rowCallback = (data,e) ->
			if data.key
				new PopupForm('zipcode', 'code', data.key, _columns)
		true

	addTestButton "popup table", "Open", ()->
		addHolder('renderTest1')
		zipCodeTable = new TableView $("#renderTest1")
		zipCodeTable.addTable "zipcode"
		zipCodeTable.on "click_city", (row, e) =>
			console.log "You clicked on something in City:", row

		popup = new PopupTable zipCodeTable, 'zipCodeDemoTable'
		$('#renderTest1').remove()
		true

	addTestButton "table with fixed header and scrollable", "Open", ()->
		addHolder("renderTest1")
		$('#renderTest1').height(350); ##| to add scroll the height is fix
		table = new TableView $("#renderTest1")
		table.addTable "zipcode"
		table.setFixedHeaderAndScrollable()
		table.render()
		true
	go()
