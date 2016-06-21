## -------------------------------------------------------------------------------------------------------------
## class TableViewDetailed widget to display the table in vertical manner it mostly used to display single row
## including all data for the single row
##
## @extends [TableView]
##
class TableViewDetailed extends TableView

	# @property [Integer] leftWidth
	leftWidth : 180

	## -------------------------------------------------------------------------------------------------------------
	## addTable function overriden from TableView
	##
	## @param [String] tableName name of the table to consider from datamap
	## @param [Function] rowReduceFunction will be applied to each row and if returns true then only row will be included
	## @param [Function] reduceFunction will be applied to each column and if returns true then only column will be included
	## @return [Boolean]
	##
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

	## -------------------------------------------------------------------------------------------------------------
	## render the table overriden from TableView
	##
	## @param [String] dataKey key to be considered from the datamap, the row with given key will be rendered
	## @return [Boolean]
	##
	render : (@dataKey) =>

		newPromise ()=>

			yield DataMap.clearPendingPromises()

			if !@dataKey?
				throw new Error "data with key #{@dataKey} not found"

			##|
			##|  Create a unique ID for the table, that doesn't change
			##|  even if the table is re-drawn
			if typeof @gid == "undefined"
				@gid = GlobalValueManager.NextGlobalID()

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
				@rowData[@dataKey][column.col.source] = yield DataMap.getDataField @primaryTableName,@dataKey,column.col.source
				if @showCheckboxes and @primaryTableName
					html += @renderCheckable(i)
				if column.col.visible != false
					html += "<th style='text-align: right;width: #{@leftWidth}px; '> "
					html += column.col.name
					html += "</th>"
					html += yield DataMap.renderField "td", column.tableName, column.col.source, @dataKey, column.col.extraClassName

				html += "</tr>";

			html += "</tbody></table>";

			@elTheTable = @elTableHolder.html(html);
			@contextMenuCallSetup = 0
			@setupContextMenuHeader()
			@internalSetupMouseEvents()

			true
