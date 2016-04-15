class TableViewDetailed extends TableView

	leftWidth : 140

	addTable: (tableName, @rowReduceFunction, @reduceFunction) =>

		@primaryTableName = tableName

		##|
		##|  Find the columns for the specific table name
		columns = DataMap.getColumnsFromTable(tableName, @rowReduceFunction)
		for col in columns
			c = new TableViewCol tableName, col
			c.inlineSorting = @inlineSorting
			@colList.push(c)
		true

	render : (@dataKey) =>

		if !@dataKey or typeof DataMap.getDataMap().data[@primaryTableName][@dataKey] != 'object'
			throw new Error "data with key #{@dataKey} not found"

		##|
		##|  Create a unique ID for the table, that doesn't change
		##|  even if the table is re-drawn
		if typeof @gid == "undefined"
			@gid = GlobalValueManager.NextGlobalID()

		# @processTableConfig()

		##|
		##|  draw the table header
		html = "<table class='detailview' id='table#{@gid}'>"

		##|
		##|  Start adding the body
		html += "<tbody id='tbody#{@gid}'>";

		@rowData[@dataKey] = {}

		for column in @colList

			column.styleFormat = ""
			column.width       = ""
			if !column.visible then continue

			##|
			##|  Create the "TR" tag
			html += "<tr class='trow' data-id='#{@dataKey}' "
			html += ">"
			@rowData[@dataKey][column.col.source] = DataMap.getDataField @primaryTableName,@dataKey,column.col.source
			if @showCheckboxes and @primaryTableName
				html += @renderCheckable(i)
			if column.col.visible != false
				html += "<th style='text-align: right; width: #{@leftWidth}px; '> "
				html += column.col.name
				html += "</th>"
				html += DataMap.renderField "td", column.tableName, column.col.source, @dataKey, column.col.extraClassName


			html += "</tr>";

		html += "</tbody></table>";

		@elTheTable = @elTableHolder.html(html);


		@contextMenuCallSetup = 0
		@setupContextMenuHeader()
		@internalSetupMouseEvents()

		true
