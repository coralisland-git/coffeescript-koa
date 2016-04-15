##|
##| Helper class for the TableView widget.   This is a popup window
##| that takes a table and allows the columns to be selected.
##|

class PopupWindowTableConfiguration extends PopupWindow

	show: (refTable) =>

		#@resize 900, 700
		@tableConfig = new TableView(@windowScroll, true)
		@tableConfig.tableConfigDatabase = "#{refTable.primaryTableName}_#{refTable.gid}"

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
		for key,_row of refTable.customizableColumns
			_column = (refTable.colList.filter (c) => c.col.source == _row).pop()
			DataMap.addData "#{@tableConfig.tableConfigDatabase}", _row, {name:_column.col.name,tooltip:_column.col.tooltip,checked:_column.col.visible}
			# col.checked = col.visible != false
			# @tableConfig.addRow col

		@tableConfig.addTable "#{@tableConfig.tableConfigDatabase}"
		@tableConfig.render()

		@tableConfig.onSetCheckbox = (checkbox_key, value) =>
			console.log "HERE", checkbox_key, value
			user.tableConfigSetColumnVisible refTable.tableCacheName, checkbox_key, value

		@open()
