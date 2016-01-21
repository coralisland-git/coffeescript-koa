##|
##| Helper class for the TableView widget.   This is a popup window
##| that takes a table and allows the columns to be selected.
##|

class PopupWindowTableConfiguration extends PopupWindow

	show: (refTable) =>

		@resize 900, 700
		@tableConfig = new TableView(@windowScroll, refTable.tableCacheName, "name")
		@tableConfig.tableConfigDatabase = refTable.tableConfigDatabase

		c = @tableConfig.addColumn("title", "Title")
		f = c.initFormat "text"
		f.setWidth "110px"

		c = @tableConfig.addColumn "tooltip", "Additional Information"
		c.initFormat "text"

		for col in refTable.colList
			col.checked = col.visible != false
			@tableConfig.addRow col

		@tableConfig.setHeight @getBodyHeight()
		@tableConfig.render()

		@tableConfig.onSetCheckbox = (checkbox_key, value) =>
			user.tableConfigSetColumnVisible refTable.tableCacheName, checkbox_key, value

		@open()




