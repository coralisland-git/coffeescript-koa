## -------------------------------------------------------------------------------------------------------------
## class TableViewCol to create and render single column for the table
## global functions required to use tables. the cell id is a counter
## used to create elements with a new unique ID
##
class TableViewColBase

	getName: ()->
		return "No name"

	getSource: ()->
		return ""

	getOrder: ()->
		return 999

	getClickable: ()->
		return false

	getEditable: ()->
		return false

	getAlign: ()->
		return null

	calculateWidth: ()=>
		return @width || 0

	RenderHeader: (parent, location) =>
		parent.html "No RenderHeader"

	RenderHeaderHorizontal: (parent, location) =>
		parent.html "No RenderHeaderHorizontal"

	UpdateSortIcon: (newSort)->
		return null

	getVisible: ()->
		return true


class TableViewCol extends TableViewColBase

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
	##|  Return the name of the column
	getName: ()=>
		return @col.name

	##|
	##|  Returns the name of the source field in the datamap
	getSource : ()=>
		return @col.source

	getOrder: ()=>
		return @col.order

	getVisible: ()=>
		if @isGrouped? and @isGrouped == true then return false
		if @col.visible? and @col.visible == true then return true
		if @col.visible? and @col.visible == false then return false
		return true

	getClickable: ()=>

		if @clickable? and @clickable == true
			return true

		if @clickable? and @clickable == false
			return false

		if @col.clickable? and @col.clickable == true
			return true

		if @col.clickable? and @col.clickable == false
			return false

		if @col.formatter.clickable? and @col.formatter.clickable == true
			return true

		return false

	##|
	##|  returns true if the field is editable
	getEditable: ()=>
		return @col.editable

	##|
	##|  Returns the name of the foramtter for this field
	getFormatterName: ()=>
		return @col.formatter.name

	getAlign: ()=>
		if @col.align? and @col.align.length > 0
			return @col.align

		if @col.formatter.align?
			return @col.formatter.align

		return null

	onFocus: (e, col, data) =>
		if @col? and @col.formatter? and @col.formatter.onFocus?
			@col.formatter.onFocus e, col, data
		true

	calculateWidth: ()=>

		##| if width is 0 then consider as auto width = left padding + max length text width + right padding
		if (@width is 0 || @width is '0px' || @width is "" )
			if @col.formatter? and @col.formatter.width?
				return @col.formatter.width

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
	RenderHeader: (parent, location) =>

		if @visible == false then return

		parent.html @getName()
		parent.addClass "tableHeaderField"

		if @sort? and @sort != 0
			@tagSort = parent.add "i", "fa fa-sort table-sorter pull-right"

		return parent

	RenderHeaderHorizontal: (parent, location) =>

		if @visible == false then return

		parent.html @getName()
		parent.addClass "tableHeaderFieldHoriz"

		if @col.tooltip? and @col.tooltip.length > 0
			parent.setAttribute "tooltip", "simple"
			parent.setAttribute "data-title", @col.tooltip

		# @tagSort = parent.add "i", "fa fa-sort table-sorter"
		# @tagSort.el.css
			# "float" : "left"
			# "padding-right" : "20"

		parent.el.css
			"text-align"       : "right"
			"padding-right"    : 8
			"border-right"     : "1px solid #CCCCCC"
			"background-color" : "linear-gradient(to right, #fff, #f2f2f2);"

		@sort    = 0

		return parent

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

