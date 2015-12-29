allTests = []
counter  = 0

##|
##|  Very simple call that takes a label (some notes for the user) and
##|  a javascript block to execute as the test.   The code and label are
##|  displayed to the user, the block is executed by a timer in the "go"
##|  function.   Each block is executed in turn.
##|
addTest = (label, fnCall, code) ->

	if !code? or not code
		code = fnCall.toString()
		code = code.replace "<", "&lt;"
		code = code.replace ">", "&gt;"
		code = code.replace "function () {\n", ""
		code = code.replace /[\r\n]*}$/, ""
		code = code.replace "\n", "<br>"

	label = label.replace " (", "<br>("

	html = "
		<tr><td class='test_label'> #{label} </td>
			<td class='test_result'> <div id='result#{counter}'></div> </td>
			<td class='test_code'> <code><pre>#{code}</pre></code> </td>
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

go = () ->

	if allTests.length == 0

		window.elTestCase.append $ "<p> Complete. </p>"
		return

	else

		try
			result = allTests[0].callback()
			t = typeof result
			if typeof t == "string"
				$(allTests[0].tag).html result
			else
				$(allTests[0].tag).append result

			allTests.splice 0, 1
			setTimeout () ->
				go()
			, 100
		catch e
			console.log "Exception:", e

			$(allTests[0].tag).html "<div class='exception'>Exception: " + e + "</div>"


$ ->

	console.log "Test Framework Loaded"

	##|
	##|  Add a table to hold the results
	window.elTestCase = $("#testCase")
	window.elTestCase.html "<table id='testTable' class='testTable'></table>"

	##|  save a reference to the results table
	window.elTestTable = $("#testTable")



