allTests        = []
counter         = 0
wgtMain         = null
viewTestCode    = null
viewTestCases   = null
viewTestExecute = null

##|
##|  Common function to load test data
##|  Load a list of zipcodes
loadZipcodes = ()->

	##|
	##|  Load the zipcode data before the test begins
	new Promise (resolve, reject) ->

		$.get "/js/test_data/zipcodes.json", (allData)->

			counter = 0
			for rec in allData.data
				rec.Weather = "https://www.wunderground.com/cgi-bin/findweather/getForecast?query=pz:#{rec.code}&zip=1"
				DataMap.addDataUpdateTable "zipcode", rec.code, rec

			resolve(true)

loadStockData = ()->

	new Promise (resolve, reject)->

		$.get "/js/test_data/stocks.json", (allData)->
			for idx, rec of allData
				delete rec._id
				DataMap.addDataUpdateTable "stocks", rec.Ticker, rec

			resolve(true)

loadDatafromJSONFile = (fileName) ->
	new Promise (resolve, reject)->

		$.get "js/test_data/#{fileName}.json", (allData)->
			for rec in allData
				DataMap.addDataUpdateTable "#{fileName}", rec.id, rec

			resolve(true)

addHolder = (name) ->
	return viewTestExecute.addHolder(name)

addHolderWidget = (name, w, h)->
	w = viewTestExecute.addHolder name
	w.setSize(w, h)
	return w

allTestData = {}

##|
##|  Very simple call that takes a label (some notes for the user) and
##|  a javascript block to execute as the test.   The code and label are
##|  displayed to the user, the block is executed by a timer in the "go"
##|  function.   Each block is executed in turn.
##|
addTest = (label, fnCall, code) ->

	test_id = GlobalValueManager.NextGlobalID()

	if !code? or not code
		code = fnCall.toString()
		code = code.replace /</g, "&lt;"
		code = code.replace />/g, "&gt;"
		code = code.replace "function () {\n", ""
		code = code.replace /[\r\n]*}$/, ""
		code = code.replace "\n", "<br>"

	label = label.replace " (", "<br>("

	html = "
		<div class='test_case' id='case_#{test_id}'>
			<div class='test_label' id='test_#{test_id}'> #{label} </div>
			<div class='test_result' id='result_#{test_id}'> </div>
		</div>
	"

	el = $("#testCases").append($(html))

	allTestData[test_id] =
		label   : label
		callback: fnCall
		code    : code
		tag     : $("#result_" + test_id)

	elTestCase = el.find("#case_#{test_id}")
	elTestCase.attr "data-id", test_id
	elTestCase.bind "click", (e)=>
		id = $(e.currentTarget).attr("data-id")
		viewTestCode.setCode allTestData[id].code
		console.log "CLICK=", id, e
		true

	allTests.push allTestData[test_id]
	true

addTestButton = (label, buttonText, fnCall) ->

	code = fnCall.toString()
	code = code.replace "<", "&lt;"
	code = code.replace ">", "&gt;"
	code = code.replace "function () {\n", ""
	code = code.replace /[\r\n]*}$/, ""
	code = code.replace "\n", "<br>"
	addTest label, ()->

		button = $ "<div />",
			class: "btn btn-primary"
			html: buttonText
		.bind 'click', (e) ->
			e.preventDefault()
			e.stopPropagation()
			viewTestCode.setCode code
			fnCall(e)
	, code

goNext = () ->

	allTests.splice 0, 1
	setTimeout () ->
		go()
	, 100

go = () ->

	if allTests.length == 0

		return

	else

		try
			Prism.highlightAll()

			result = allTests[0].callback()

			if typeof result == "function"
				result = result()

			if typeof result != "object"
				$(allTests[0].tag).html result
				goNext()
			else

				if result.constructor.toString().match /Promise/

					result.then (trueResult) ->
						$(allTests[0].tag).append trueResult
						goNext()
					.catch (e)  ->
						strText = e.toString()
						strText += "<br>" + e.stack

						$(allTests[0].tag).append "Exception:" + strText

				else

					$(allTests[0].tag).append result
					goNext()

		catch e

			console.log "Exception:", e
			console.log "Stack:", e.stack

			$(allTests[0].tag).html "<div class='exception'>Exception: " + e + "</div>"

##|
##|  Setup the main widget that holds everything
onResizeWindow = ()->

	winw = $(window).width()
	winh = $(window).height()
	offset = wgtMain.offset()

	##|
	##|  Remove space on the left for that left side menu
	##|  todo: use css to measure
	offset_left = 250
	wgtMain.move offset_left, 0, winw-offset_left, winh
	true

$ ->

	console.log "TestCommon 1.0"

	globalTableEvents.on "set_custom", (tableName, source, field, newValue)=>
		console.log "globalTableEvents: table=#{tableName} source=#{source} field=#{field} new=", newValue
		true

	globalTableEvents.on "row_selected", (tableName, id, status)=>
		console.log "globalTableEvents: rowSelected tableName=#{tableName}, id=#{id}, status=#{status}"
		true

	el = $("#mainTestArea")
	wgtMain = new WidgetTag(el)
	wgtMain.setAbsolute()
	onResizeWindow()

	##|
	##|  Add a splitter
	wgtMain.setView "Splittable", (splitter1)->

		splitter1.getFirst().setView "TestExecute", (view)->
			viewTestExecute = view

		splitter1.setPercent 80
		splitter1.getSecond().setMinWidth 500
		splitter1.getSecond().setView "Splittable", (splitter2)->
			splitter2.setHorizontal()
			splitter2.setPercent 50
			splitter2.getFirst().setView "TestCases", (view)->
				viewTestCases = view
				view.setScrollable()
				onResizeWindow()

			splitter2.getSecond().setView "TestCode", (view)->
				viewTestCode = view

		wgtMain.resetSize()
		splitter1.resetSize()

	, 80

	##|
	##|  Watch for browser changes
	$(window).on "resize", onResizeWindow


	# DataMap.getDataMap().on "table_change", (tableName, config)->
	# 	console.log "DataMap.table_change tableName=#{tableName} config=", config
	# 	true

	##|
	##|  Add a table to hold the results
	# window.elTestCase = $("#testCase")
	## -xg
	# responsiveTable = new WidgetTag "div", "table-responsive"
	# responsiveTable.appendTo "#testCase"
	# responsiveTable.add "table", "testTable table", "testTable"
	#window.elTestCase.html "<div class='table-responsive'><table id='testTable' class='testTable table'></table></div>"

	##|  save a reference to the results table
	# window.elTestTable = $("#testTable")




