## -------------------------------------------------------------------------------------------------------------
## Helper class for the TableView widget. This is a popup window
## that takes a table and allows the columns to be selected.
##
class PopupWindowTableConfiguration extends PopupWindow

	## -------------------------------------------------------------------------------------------------------------
	## show the configurations for the reference tabel passed as arg
	##
	## @param [TableView] refTable the refernce table for which configuration is running
	##
	show: (refTable) =>

		@popupWidth = 300
		@tableConfig = new TableView(@windowScroll, true)
		@tableConfig.tableConfigDatabase = "#{refTable.primaryTableName}_#{refTable.gid}"
		@tableConfig.showFilters = false
		console.log "tableConfigDatabase=", @tableConfig.tableConfigDatabase

		columns = []
		columns.push
			name   : "Title"
			source : "name"
			type   : "text"
			visible: true
			width: 120

		columns.push
			name   : "Additional Information"
			source : "tooltip"
			type   : "text"
			visible: true
			width: 150

		DataMap.setDataTypes "#{@tableConfig.tableConfigDatabase}", columns

		# for col in refTable.colList
		# 	console.log "COL=", col
		for row in refTable.colList
			console.log row.col.name, row.col.hideable
			if row.col.hideable
				DataMap.addData "#{@tableConfig.tableConfigDatabase}", row.col.source, {name:row.col.name,tooltip:row.col.tooltip}

		@tableConfig.addTable "#{@tableConfig.tableConfigDatabase}"

		for key,row of @tableConfig.rowData
			column = refTable.colList.filter (c) =>
				console.log c, row
				c.col.source == row.key
			column = column.pop();
			row.checked = column.col.visible
		@tableConfig.render()

		@tableConfig.onSetCheckbox = (checkbox_key, value) =>
			console.log "HERE", checkbox_key, value
			source = checkbox_key.split('_')[checkbox_key.split('_').length-1]
			column = (refTable.colList.filter (c) => c.col.source == source).pop()
			## setting up in the datamap
			column.visible = value
			DataMap.getDataMap().types[refTable.primaryTableName].configureColumn column.col

			## setting up in the current table instance
			i = refTable.colList.indexOf(column);
			refTable.colList[i].col.visible = value
			localStorage.setItem("tableConfigSetColumnVisible", refTable.primaryTableName, checkbox_key, value)
			refTable.render()
		@center()
		@open()
