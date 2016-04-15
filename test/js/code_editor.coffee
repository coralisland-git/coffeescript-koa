$ ->

	addTestButton "Basic Code Editor", "Open", ()->

		addHolder("renderTest1");

		editor = new CodeEditor $("#renderTest1")

		true

	addTestButton "Code Editor with theme", "Open", ()->

		addHolder("renderTest1");

		editor = new CodeEditor $("#renderTest1")
		# make sure the js of the theme is included
		editor.setTheme("tomorrow_night_eighties")
		true

	addTestButton "Code Editor with theme and options and content api", "Open", ()->

		addHolder("renderTest1");

		editor = new CodeEditor $("#renderTest1")
		# make sure the js of the theme is included
		editor.setTheme("tomorrow_night_eighties").setOptions
			enableBasicAutocompletion: true
			enableSnippets: true
			enableLiveAutocompletion: true
		.setContent "select * from users"
		true

	addTestButton "Code Editor with change event", "Open", ()->
		addHolder("preview");
		$("#preview").append '<span></span>'
		addHolder("renderTest1");
		editor = new CodeEditor $("#renderTest1")
		# make sure the js of the theme is included
		editor.setTheme("tomorrow_night_eighties").onChange (content,editor) ->
			$("#preview span").html content
		true

	addTestButton "Code Editor with mongoDB(javascript) mode", "Open", ()->
		addHolder("renderTest1");
		editor = new CodeEditor $("#renderTest1")
		# make sure the js of the theme is included
		editor.setTheme("tomorrow_night_eighties").setMode('javascript')
		true

	addTestButton "Code Editor with histories", "Open", ()->
		addHolder("renderHistories");
		addHolder("renderTest1");
		##| to make little bit space it should be done using css
		$ "#renderTest1"
			.css 'margin-top', '20px'

		editor = new CodeEditor $("#renderTest1")
		# make sure the js of the theme is included
		editor.setTheme("tomorrow_night_eighties")
		editor.addToHistory "select * from users"
		editor.addToHistory "select * from abc"
		editor.renderHistories $('#renderHistories'), (updatedValue,element) ->
			editor.setContent updatedValue
			element.val ''

		$ "#renderTest1"
			.after "<button id='add' class='btn btn-primary'>Add To History</button>"

		$ "#add"
			.on "click", () ->
				editor.addToHistory editor.getContent()
				editor.refreshHistories()
		true

	go()
