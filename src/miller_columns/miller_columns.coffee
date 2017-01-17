###

 Class:  MillerColumns
 =====================================================================================

 This is class to render MillerColumns using given element

 @example:
 new MillerColumns $("#container"), isReadOnly

###

class MillerColumns
	
	## -------------------------------------------------------------------------------------------------------------
	## Initialize the class by sending in the dom element to use and if it will be readonly
	## This should be a simple <div id='something'> tag.
	##
	## @param [JQueryElement] elMillerHolder the $() referenced element that will hold the miller columns
	## @param [Boolean] isReadOnly if options can be updated
	##
	constructor: (@elMillerHolder, @isReadOnly) ->

	## -------------------------------------------------------------------------------------------------------------
	## to add data in the millerColumn
	##
	## @example millercolumn.setData {}
	## @param [Object] millerData will be the object containing the initData for millerColumn
	## @see https://github.com/dsharew/responsive-miller-column#-json-support-
	##
	setData: (@millerData) ->

	## -------------------------------------------------------------------------------------------------------------
	## render the millerColumn with initialization
	##
	render: =>
		if (!$.fn.millerColumn)
			console.log 'Error: millerColumn plugin js is not included'
			return

		@millerColumn = @elMillerHolder.millerColumn
			isReadOnly: @isReadOnly,
			initData: @millerData

		@bindEvents()

	## -------------------------------------------------------------------------------------------------------------
	## bind the events of millerColumn to deligate with current instance
	##
	bindEvents: =>
		if !@millerColumn
			return;
		@elMillerHolder.on "item-selected", ".miller-col-list-item", (e, data) =>
			@filterDataWithParentCategory data.categoryId, data.itemId
			@onSelected(e, data)

	## -------------------------------------------------------------------------------------------------------------
	## filter the data for given category and whose parents are given id,
	## when dataMap is used here it should filter the data which has categoryId and parentId as passed params
	## once filtered items are collected it renders new column inside MillerColumn using its api
	##
	filterDataWithParentCategory: (categoryId, parentId) =>
		subItems = []
		parentItem = false
		$.each @millerData.items, (i, item) ->
			if item.categoryId is categoryId and !parentItem
				parentItem = item
			if item.parentId is parentId and item.categoryId is categoryId
				subItems.push item
		parentItem.items = subItems
		@elMillerHolder.millerColumn("addCol", parentItem);



	## -------------------------------------------------------------------------------------------------------------
	## when the item is selected it will call this callback you can override it.
	##
	## @example millercolumn.onSelected = (event, item) ->
	## @param [jQueryEvent] event event object from jquery
	## @param [Object] data the selected item as instance of CategoryItem
	##
	onSelected: (event, data) =>
		console.log 'item is selected with data ', data

	