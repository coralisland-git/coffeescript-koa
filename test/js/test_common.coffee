allTests = []
counter  = 0

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

	$("#" + name).remove()
	$("#testCase").append($("<div id='" + name + "' style='padding-top: 20px;' />"))

	##|
	##| Added by @xgao
	##| Automatically scroll down to where the newly added element is appears.
	##|
	###setTimeout ->
		document.getElementById(name).scrollIntoView()
	, 500
	###
	$('html, body').animate {
       scrollTop: $('#' + name).offset().top
    }, 1000

	true

addHolderWidget = (name, w, h)->

	@addHolder("test_#{name}")
	div = new WidgetTag "div", "testWidget"
	div.appendTo("#test_#{name}")
	return div

##|
##|  Very simple call that takes a label (some notes for the user) and
##|  a javascript block to execute as the test.   The code and label are
##|  displayed to the user, the block is executed by a timer in the "go"
##|  function.   Each block is executed in turn.
##|
addTest = (label, fnCall, code) ->

	if !code? or not code
		code = fnCall.toString()
		code = code.replace /</g, "&lt;"
		code = code.replace />/g, "&gt;"
		code = code.replace "function () {\n", ""
		code = code.replace /[\r\n]*}$/, ""
		code = code.replace "\n", "<br>"

	label = label.replace " (", "<br>("

	html = "
		<tr><td class='test_label'> #{label} </td>
			<td class='test_result'> <div id='result#{counter}'></div> </td>
			<td class='test_code'> <pre><code class='language-javascript'>#{code}</code></pre> </td>
		</tr>
	"

	if !window.elTestTable? or not 	window.elTestTable
		window.elTestTable = $("#testTable")

	window.elTestTable.append html

	test =
		label:    label
		callback: fnCall
		tag:      $("#result" + counter)

	allTests.push test

	counter++

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
			fnCall(e)
	, code

goNext = () ->

	allTests.splice 0, 1
	setTimeout () ->
		go()
	, 100

go = () ->

	if allTests.length == 0

		window.elTestCase.append $ "<br><p> Complete. </p>"
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


$ ->

	globalTableEvents.on "set_custom", (tableName, source, field, newValue)=>
		console.log "globalTableEvents: table=#{tableName} source=#{source} field=#{field} new=", newValue
		true

	globalTableEvents.on "row_selected", (tableName, id, status)=>
		console.log "globalTableEvents: rowSelected tableName=#{tableName}, id=#{id}, status=#{status}"
		true

	# DataMap.getDataMap().on "table_change", (tableName, config)->
	# 	console.log "DataMap.table_change tableName=#{tableName} config=", config
	# 	true

	##|
	##|  Add a table to hold the results
	window.elTestCase = $("#testCase")
	window.elTestCase.html "<div class='table-responsive'><table id='testTable' class='testTable table'></table></div>"

	##|  save a reference to the results table
	window.elTestTable = $("#testTable")

	##|
	##|  Check for a hash value and load a test page
	if document.location.search?
		m = document.location.search.match /page=(.*)/
		if m? and m[1]
			page = m[1]
			$("body").append "<script src='/js/" + page + ".js' /></script>"


