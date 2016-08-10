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
		@showHeaders = false
		@showFilters = false
		@primaryTableName = tableName

		##| create 2 columns for table Field Name, Field Value
		fieldName = {
			editable: false
			extraClassName: ''
			hideable: false
			name: 'Field Name'
			required: false
			sortable: false
			source: 'field'
			type: 'text'
			visible: true
			align: 'left',
			calculateWidth: () =>
				return 100
		}
		fieldValue = {
			editable: false
			extraClassName: ''
			hideable: false
			name: 'Field Value'
			required: false
			sortable: false
			source: 'value'
			type: 'text'
			visible: true
			align: 'right'
		}
		@colList = [new TableViewCol "detailed_#{@primaryTableName}", fieldName, new TableViewCol "detailed_#{@primaryTableName}", fieldValue]

	## -------------------------------------------------------------------------------------------------------------
	## render the table overriden from TableView
	##
	## @param [String] dataKey key to be considered from the datamap, the row with given key will be rendered
	## @return [Boolean]
	##
	render : (@dataKey) =>

		if !@dataKey?
			throw new Error "data with key #{@dataKey} not found"

		##|
		##|  Create a unique ID for the table, that doesn't change
		##|  even if the table is re-drawn
		if typeof @gid == "undefined"
			@gid = GlobalValueManager.NextGlobalID()

		@elTableHolder.html("")
		@widgetBase = new WidgetBase()

		tableWrapper   = @widgetBase.addDiv "table-wrapper", "tableWrapper#{@gid}"
		outerContainer = tableWrapper.addDiv "outer-container"
		@elTheTable    = outerContainer.addDiv "inner-container detailview"

		@virtualScrollV = new VirtualScrollArea outerContainer, true
		@virtualScrollH = new VirtualScrollArea outerContainer, false
		##|
		##|  draw the table header
		# html = "<table class='detailview' id='table#{@gid}'>"

		##|
		##|  Start adding the body
		# html += "<tbody id='tbody#{@gid}'>";


		row = []
		@shadowRows = []
		# maxRows = @getMaxVisibleRows()
		# if maxRows > @totalAvailableRows
		# 	@virtualScrollV.hide()
		# 	maxRows = @totalAvailableRows
		columns = {}
		for c in DataMap.getColumnsFromTable(@primaryTableName, @rowReduceFunction)
			columns[c.source] = c

		for source, column of columns
			dataValue = DataMap.getDataField @primaryTableName,@dataKey, source
			@rowDataRaw.push({field: column.name, value: dataValue})

		rowNum = 0
		for source, column of columns
			column.styleFormat = ""
			column.width       = ""
			if !column.visible then continue
			row = []
			rowTag = @elTheTable.add "row"
			row.push rowTag.addDiv "#{column.formatter.name} #{editable}"
			editable = ""
			if column.editable then editable = " editable"
			if rowNum++ % 2 == 0 then editable += " even"
			if column.align == "right" then editable += " text-right"
			if column.align == "center" then editable += " text-center"
			editable += " col_" + column.source
			colTags = rowTag.addDiv "#{column.formatter.name} #{editable}"
			# colTag.text "r=#{rowNum},#{i.getSource()}"
			row.push colTags
			@shadowRows.push row
			console.log @shadowRows
		@layoutShadow()
		@updateVisibleText()
		@internalSetupMouseEvents()
		@elTableHolder.append tableWrapper.el
			##|
			##|  Create the "TR" tag
			# html += "<tr class='trow' data-id='#{@dataKey}' "
			# html += ">"
			# @rowDataRaw[@dataKey][column.col.source] = DataMap.getDataField @primaryTableName,@dataKey,column.col.source
			#if @showCheckboxes and @primaryTableName
			#	html += @renderCheckable(i)
			#if column.col.visible != false
			#	html += "<th style='text-align: right;width: #{@leftWidth}px; '> "
			#	html += column.col.name
			#	html += "</th>"
			#	html += DataMap.renderField "td", column.tableName, column.col.source, @dataKey, column.col.extraClassName

			#html += "</tr>";

		#html += "</tbody></table>";

		# @elTableHolder.append tableWrapper.el
		# @contextMenuCallSetup = 0
		# @setupContextMenu()
		# @internalSetupMouseEvents()

		true
