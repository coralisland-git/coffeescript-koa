##|
##| Helper class for the TableView widget.   This is a popup window
##| that takes a table and allows the columns to be selected.
##|

class PopupWindowTableConfiguration extends PopupWindow

	show: (refTable) =>

		@resize 900, 700
		@tableConfig = new TableView(@windowScroll, refTable.tableCacheName, "name")
		@tableConfig.tableConfigDatabase = refTable.tableCacheName

		console.log "tableConfigDatabase=", @tableConfig.tableConfigDatabase

		columns = []
		columns.push
			name   : "Title"
			source : "name"
			type   : "text"
			width  : "110px"

		columns.push
			name   : "Additional Information"
			source : "tooltip"
			type   : "text"

		DataMap.setDataTypes "colConfig", columns

		for col in refTable.colList
			console.log "COL=", col
			# col.checked = col.visible != false
			# @tableConfig.addRow col

		@tableConfig.addTable "colConfig"
		@tableConfig.render()

		@tableConfig.onSetCheckbox = (checkbox_key, value) =>
			console.log "HERE", checkbox_key, value
			user.tableConfigSetColumnVisible refTable.tableCacheName, checkbox_key, value

		@open()




