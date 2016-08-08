## -------------------------------------------------------------------------------------------------------------
## class TableViewCol to create and render single column for the table
## global functions required to use tables. the cell id is a counter
## used to create elements with a new unique ID
##
class TableViewCol

	## -------------------------------------------------------------------------------------------------------------
	## constructor create new column object
	##
	## @param [String] name The name of the column
	## @param [String] title The title to show in the header
	##
	constructor : (@tableName, @col) ->
		@visible = @col.visible
		@width   = @col.width

		if !@visible? then @visible = true
		if !@width? then @width = ""

	##|
	##|  Returns the name of the source field in the datamap
	getSource : ()=>
		return @col.source

	##|
	##|  returns true if the field is editable
	getEditable: ()=>
		return @col.editable

	##|
	##|  Returns the name of the foramtter for this field
	getFormatterName: ()=>
		return @col.formatter.name

	getAlign: ()=>
		return @col.align

	calculateWidth: ()=>

		##| if width is 0 then consider as auto width = left padding + max length text width + right padding
		if (@width is 0 || @width is '0px' || @width is "" )
			return null

		if typeof @width == "string"
			return parseInt(@width)

		return @width

	## -------------------------------------------------------------------------------------------------------------
	## RenderHeader function to render the header for the column
	##
	## @param [String] extraClassName extra class name that will be included in the th
	## @return [String] html the html for the th
	##
	RenderHeader: (extraClassName, parent) =>

		if @visible == false then return

		if !@col.extraClassName?
			@col.extraClassName = ""

		if extraClassName
			if @col.extraClassName.length then @col.extraClassName += " "
			@col.extraClassName += extraClassName

		tag = parent.addDiv "#{@col.formatter.name} tableHeaderField " + @col.extraClassName

		if @col.tooltip? and @col.tooltip.length > 0
			tag.setAttribute "tooltip", "simple"
			tag.setAttribute "data-title", @col.tooltip

		tag.setDataPath "/#{@tableName}/Header/#{@col.source}"
		tag.html @col.name

		@tagSort = tag.add "i", "fa fa-sort table-sorter pull-right"
		@sort    = 0

		return tag

	UpdateSortIcon: (newSort) =>

		console.log "newSort = ", newSort, @sort

		@sort = newSort
		@tagSort.removeClass "fa-sort"
		@tagSort.removeClass "fa-sort-up"
		@tagSort.removeClass "fa-sort-down"

		if @sort == -1
			@tagSort.addClass "fa-sort-down"
		else if @sort == 0
			@tagSort.addClass "fa-sort"
		else if @sort == 1
			@tagSort.addClass "fa-sort-up"

		true

