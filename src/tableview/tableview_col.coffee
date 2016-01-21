##|
##|  Global functions required to use tables.  The cell id is a counter
##|  used to create elements with a new unique ID
##|

class TableViewCol

	##|
	##| Create a new column object.
	##|
	##| @param name [string] The name of the column
	##| @param title [string] The title to show in the header
	constructor : (@name, @title) ->
		@elHolder   = null
		@tagType    = "td"
		@dataType 	= null

	checkHolderElement: () =>
		if @elHolder == null
			@elHolder = $("#c#{@gid}")

		true

	##|
	##|  Initialize the column based on a type and options
	##|  The type must be one of the types supported by data_type_collection
	##|
	initFormat: (@dataType, @options) =>
		@formatter = globalDataFormatter.getFormatter @dataType
		true

	RenderHeader: =>
		if @visible == false then return ""

		if typeof @formatter == "undefined" or @formatter == null
			@initFormat "text"

		html = "<th style='";
		if (@formatter.width) then html += "width: " + @formatter.width + ";"

		html += @formatter.styleFormat + "'"

		if typeof @tooltip != "undefined"
			html += " tooltip='simple' data-title='#{@tooltip}'"

		html += ">";
		html += @title;
		html += "</th>";
		return html

	onClickLink: ()=>

		window.open(@link, "showWindow", "height=800,width=1200,menubar=no,toolbar=no,location=no,status=no,resizable=yes")







