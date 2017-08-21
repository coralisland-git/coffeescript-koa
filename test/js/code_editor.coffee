$ ->

	addTestButton "Basic Code Editor", "Open", ()->
		addHolder().setView "CodeEditor", (view)->
			view.showEditor()

		true

	addTestButton "Code Editor with theme", "Open", ()->

		addHolder().setView "CodeEditor", (view)->
			view.showEditor()
			# make sure the js of the theme is included
			view.setTheme("tomorrow_night_eighties")
		true

	addTestButton "Code Editor with theme and options and content api", "Open", ()->

		addHolder().setView "CodeEditor", (view)->
			view.showEditor()
			# make sure the js of the theme is included
			view.setTheme("tomorrow_night_eighties").setOptions
				enableBasicAutocompletion: true
				enableSnippets: true
				enableLiveAutocompletion: true
			.setContent "select * from users"
		true

	addTestButton "Code Editor with change event", "Open", ()->
		addHolder().setView "Docked", (dockedView)->
			dockedView.getFirst().html '<div id="preview" style="padding: 10px;"></div>'
			dockedView.getSecond().setView "CodeEditor", (editorView)->
				editorView.showEditor()
				editorView.getEditorInstance().setTheme("tomorrow_night_eighties").onChange (content, editor) ->
					$("div#preview").html content
		true

	addTestButton "Code Editor with mongoDB(javascript) mode", "Open", ()->
		addHolder().setView "CodeEditor", (view)->
			view.showEditor()
			# make sure the js of the theme is included
			view.setTheme("tomorrow_night_eighties").setMode('javascript')
		true

	addTestButton "Code Editor with histories", "Open", ()->
		addHolder("renderHistories");
		addHolder("renderTest1");
		##| to make little bit space it should be done using css
		addHolder().setView "Docked", (dockedView)->
			dockedView.setDockSize 150
			divHistories = dockedView.getFirst().addDiv "", "renderHistories"
			divHistories.css "margin-bottom", "30px"
			button = dockedView.getFirst().add "button", "btn btn-primary", "add"
			button.text "Add To History"
			dockedView.getBody().setView "CodeEditor", (editorView) ->
				editorView.showEditor()
				editor = editorView.getEditorInstance()
				editor.setTheme("tomorrow_night_eighties")
				editor.addToHistory "select * from users"
				editor.addToHistory "select * from abc"
				editor.renderHistories $('#renderHistories'), (updatedValue,element) ->
					editor.setContent updatedValue
					element.val ''
				button.bind "click", () ->
					editor.addToHistory editor.getContent()
					editor.refreshHistories()
		true

	go()
