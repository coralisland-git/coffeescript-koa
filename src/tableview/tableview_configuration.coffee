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

		#@resize 900, 700
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

		columns.push
			name   : "Additional Information"
			source : "tooltip"
			type   : "text"
			visible: true

		DataMap.setDataTypes "#{@tableConfig.tableConfigDatabase}", columns

		# for col in refTable.colList
		# 	console.log "COL=", col
		for key,row of refTable.customizableColumns
			column = (refTable.colList.filter (c) => c.col.source == row).pop()
			DataMap.addData "#{@tableConfig.tableConfigDatabase}", row, {name:column.col.name,tooltip:column.col.tooltip}

		@tableConfig.addTable "#{@tableConfig.tableConfigDatabase}"

		for index,row of @tableConfig.rowData
			column = (refTable.colList.filter (c) => c.col.source == row.key).pop()
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

		@open()
