class TableViewDetailed extends TableView

	leftWidth : 140

	realRender : () =>

		##|
		##|  Create a unique ID for the table, that doesn't change
		##|  even if the table is re-drawn
		if typeof @gid == "undefined"
			@gid = GlobalValueManager.NextGlobalID()

		@processTableConfig()

		##|
		##|  draw the table header
		html = "<table class='detailview' id='table#{@gid}'>"

		##|
		##|  Start adding the body
		html += "<tbody id='tbody#{@gid}'>";

		counter = 0
		if (typeof @sort == "function")
			@rowData.sort @sort

		for col in @colList

			col.styleFormat = ""
			col.width       = ""
			if !col.visible then continue

			##|
			##|  Create the "TR" tag
			html += "<tr class='trow' data-id='#{counter}' "
			html += ">"

			if @keyColumn and @tableName
				html += @renderCheckable(i)

			if col.visible != false
				html += "<th style='text-align: right; width: #{@leftWidth}px; '> "
				html += col.title
				html += "</th>"

			for i in @rowData

				if @basePath != 0
					col.setBasePath @basePath + "/" + i.id

				col.formatter.styleFormat = "";
				html += col.Render(counter, i)

			html += "</tr>";

		html += "</tbody></table>";

		@elTheTable = @elTableHolder.html(html);

		setTimeout () =>
			globalResizeScrollable();
			setupSimpleTooltips();
		, 100

		@contextMenuCallSetup = 0
		@setupContextMenuHeader()
		@internalSetupMouseEvents()

		true