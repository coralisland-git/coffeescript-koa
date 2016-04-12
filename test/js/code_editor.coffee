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

	go()
