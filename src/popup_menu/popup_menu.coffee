window.popupMenuVisible = false
window.popupMenuHolder  = null

## -------------------------------------------------------------------------------------------------------------
## popup menu manager class
## This class creates a popup window that is managed like a list. It's used
## mainly for context menus. Only one popup menu can be shown at a time.
##
## @example
## 		popup = new PopupMenu(title, x, y)
##		popup.addItem "Item Text", callbackFunction, callbackData
##

class PopupMenu

	# @property [Integer] popupWidth width of the popup default 300
	popupWidth:  300

	# @property [Integer] popupHeight height of the popup default 0
	popupHeight: 0

	## -------------------------------------------------------------------------------------------------------------
	## change the width of the popup menu
	##
	## @param [Integer] popupWidth the new width of the popup
	##
	resize: (@popupWidth) =>

		@popupHeight = window.popupMenuHolder.height()

		width  = $(window).width()
		height = $(window).height()

		if @x < 0
			@x = 0

		if @y < 0
			@y = 0

		if @popupWidth > width - 40
			@popupWidth = width - 40

		if @x + @popupWidth + 10> width
			@x = width - @popupWidth - 10

		##| because of table context menu popup had to comment
		# if @y + @popupHeight + 10 > height
		# 	@y = height - @popupHeight - 10

		window.popupMenuHolder.css
			left:  @x
			top:   @y
			width: @popupWidth

		window.popupMenuHolder.show()

		true

	## -------------------------------------------------------------------------------------------------------------
	## constructor create new popup menu
	##
	## @param [String] title the window title
	## @param [Integer] x the adjusted X location to open
	## @param [Integer] y the adjusted Y location to open
	##
	constructor: (@title, @x, @y) ->

		##|
		##| if the 2nd parameter is an event, use that event to open the popup
		if @x? and @x and @x.currentTarget? and @x.currentTarget
			values = GlobalValueManager.GetCoordsFromEvent @x
			@x.stopPropagation()
			@x.preventDefault()
			@x = values.x - 150
			@y = values.y - 10

		if @x < 0 then @x = 0
		if @y < 0 then @y = 0

		if typeof window.popupMenuHolder == "undefined" or !window.popupMenuHolder

			window.popupMenuVisible = false
			id   = GlobalValueManager.NextGlobalID()
			html = $ "<ul />",
				class: "PopupMenu"
				id:    "popup#{id}"

			window.popupMenuHolder = $(html)
			window.popupMenuTimer  = 0
			$("body").append window.popupMenuHolder

			$(window.popupMenuHolder).on "mouseout", (e) =>
				if window.popupMenuVisible
					if window.popupMenuTimer then clearTimeout window.popupMenuTimer
					window.popupMenuTimer = setTimeout @closeTimer, 750
					false
				true

			$(window.popupMenuHolder).on "mouseover", (e) =>
				if window.popupMenuVisible
					if window.popupMenuTimer then clearTimeout window.popupMenuTimer
					window.popupMenuTimer = 0
				true

		window.popupMenuVisible = true
		window.popupMenuHolder.removeClass("multicol")
		html = "<li class='title'>" + @title + "</li>"
		window.popupMenuHolder.html(html)

		setTimeout () ->
			window.popupMenuHolder.show()
		, 10

		##|
		##|  Setup with default sizeing
		@resize 300
		@colCount  = 1
		@menuItems = {}
		@menuData  = {}

	## -------------------------------------------------------------------------------------------------------------
	## close the window after the mouse drifts away from it
	##
	closeTimer: () =>
		console.log "Popup Hide"
		window.popupMenuHolder.hide()
		window.popupMenuVisible = false
		window.popupMenuTimer = 0
		false;

	## -------------------------------------------------------------------------------------------------------------
	## Enable multiple columns in the context menu
	##
	## @param [Integer] colCount the number of columns
	##
	setMultiColumn: (@colCount) =>
		@resize 600
		window.popupMenuHolder.addClass("multicol")

	## -------------------------------------------------------------------------------------------------------------
	## add new menu item to popup
	##
	## @param [String] name the name to display
	## @param [Function] callbackFunction A function called with the callback data when the item is selected
	## @param [mixed] callbackData optional callback data to include in the callback function
	##
	addItem: (name, callbackFunction, callbackData, className) =>

		id = GlobalValueManager.NextGlobalID()
		@menuItems[id] = callbackFunction
		@menuData[id]  = callbackData

		if typeof className == "undefined"
			className = "item"

		link = $ "<li />",
			'data-id' : id
			'class'	  : className
			'html'	  : name

		if @colCount > 0
			link.addClass "multicol"

		link.on "click", (e) =>
			e.preventDefault()
			e.stopPropagation()

			##|
			##|  Close popup
			window.popupMenuHolder.hide()
			window.popupMenuVisible = false

			##|  Lookup the element selected, make a callback
			dataId = $(e.target).attr("data-id")
			if dataId
				@menuItems[dataId](e, @menuData[dataId])

			true

		window.popupMenuHolder.append link
		@resize @popupWidth

$ ->

	## -------------------------------------------------------------------------------------------------------------
	## setup an event to monitor all clicks, if someone clicks
	## while the popup menu is open, close it
	##
	$(document).on "click", (e) =>
		if window.popupMenuVisible
			window.popupMenuHolder.hide()
			window.popupMenuVisible = false
		true

	## -------------------------------------------------------------------------------------------------------------
	## close the popup with escape key
	##
	$(document).on "keypress", (e) =>
		if e.keyCode == 13
			if window.popupMenuVisible
				window.popupMenuHolder.hide()
				window.popupMenuVisible = false
		true
