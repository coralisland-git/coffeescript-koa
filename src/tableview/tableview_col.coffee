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
	constructor : (@tableName, @col) ->
		@visible = @col.visible
		@width   = @col.width

		if !@visible? then @visible = true
		if !@width? then @width = ""

	RenderHeader: (extraClassName) =>
		if @visible == false then return ""

		html = "<th style='";
		##| if width is 0 then consider as auto width = left padding + max length text width + right padding
		if(@width is 0 || @width is '0px' || @width is "" )
			@width = 2 + 4 # 4 is left padding 2 is right padding
			##| get the max length value from all data values
			_currentWord = ''
			DataMap.getValuesFromTable @tableName, (obj) =>
				_currentWord = if obj[@col.source].length > _currentWord.length then obj[@col.source] else _currentWord
			_rulerElement = $("<span id='ruler'>#{_currentWord}</span>").appendTo('body')
			@width += parseInt(_rulerElement.width())
			_rulerElement.remove()
		if (@width)
			if typeof @width == "string"
				html += "width: " + @width + ";"
			else
				html += "width: " + @width + "px;"

		html += "'"

		if !@col.extraClassName?
			@col.extraClassName = ""

		html += "class='data " + @col.extraClassName

		if @col.formatter?
			html += " dt_" + @col.formatter.name

		html += "'"

		if @col.tooltip? and @col.tooltip.length > 0
			html += " tooltip='simple' data-title='#{@col.tooltip}'"

		html += ">";
		html += @col.name;
		##| sorting icon if inline sorting
		if @inlineSorting
			html += "<i class='fa fa-sort table-sorter pull-right'></i>"
		html += "</th>";

		return html

	onClickLink: ()=>

		window.open(@link, "showWindow", "height=800,width=1200,menubar=no,toolbar=no,location=no,status=no,resizable=yes")







