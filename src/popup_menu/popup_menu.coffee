window.popupMenuVisible = false
window.popupMenuHolder  = null

## -------------------------------------------------------------------------------------------------------------
## popup menu item class to manage single popup menu item
## @example
## 		popup = new PopupMenu(title, x, y)
##		popup.addItem "Item Text", callbackFunction, callbackData
##			.setBadge(3)
##			.setIcon('fa fa-home')
##			.setClass('primary')
##
class PopupMenuItem

	## -------------------------------------------------------------------------------------------------------------
	## constructor create new popup menu
	##
	## @param [String] name the name of the popup menu to display
	## @param [String] className the class to be applied on the popup menu li
	##
	constructor: (@name, @className, id)->

		# @property [String] iconClass to store the class of icon
		@iconClass = "fa fa-fw"

		# @property [String] textClass to store class of text
		@textClass = ""

		# @property [Integer] badge to store the counter of badge
		@badge = null

		@link = $ "<li />",
			'data-id' : id
			'class'	  : @className
			'html'	  : @name

	## -------------------------------------------------------------------------------------------------------------
	## function to get the html element including badge and icon and classes
	##
	## @return [JqueryElement] jquery element including badge icons and applied settings
	##
	getRenderedElement: ->
		spanBadge = if @badge then "<div class='badge pull-right bg-#{@textClass}'>#{@badge}</div>" else ""
		iconElement = if @iconClass.length then "<i class='#{@iconClass} pull-right text-#{@textClass}'></i>" else ""
		if @textClass.length
			@link.addClass "text-#{@textClass}"
		@link.html "#{@name} #{iconElement} #{spanBadge}"

	## -------------------------------------------------------------------------------------------------------------
	## getLink function to get the link of the currently created li
	##
	## @return [JqueryElement] link jquery element
	##
	getLink: ->
		return @link

	## -------------------------------------------------------------------------------------------------------------
	## setBadge function to set the badge
	##
	## @param [Integer] number to set as the badge
	## @return [PopupMenuItem] this current instance
	##
	setBadge: (@badge) ->
		this

	## -------------------------------------------------------------------------------------------------------------
	## setIcon function to set the icon on menu item
	##
	## @param [String] iconClass to set the class name
	## @return [PopupMenuItem] this current instance
	##
	setIcon: (@iconClass) ->
		this

	## -------------------------------------------------------------------------------------------------------------
	## setClass to set the classes on li itself
	##
	## @param [String] textClass
	## @return [PopupMenuItem] this current instance
	##
	setClass: (@textClass) ->
		this


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
	popupWidth:  200

	# @property [Integer] popupHeight height of the popup default 0
	popupHeight: 0

	## -------------------------------------------------------------------------------------------------------------
	## change the width of the popup menu
	##
	## @param [Integer] popupWidth the new width of the popup
	##
	resize: (@popupWidth) =>

		## append all the popupMenuItems to the holder
		for linkObject in @linkObjects
			window.popupMenuHolder.append linkObject.getRenderedElement()

		@popupHeight = window.popupMenuHolder.height()
		@popupWidth = window.popupMenuHolder.width()

		width  = $(window).width()
		height = $(window).height()

		x = @x - @popupWidth / 2
		if x < 0
			 x = 0

		if @y < 0
			@y = 0

		if @popupWidth > width - 40
			@popupWidth = width - 40

		if x + @popupWidth + 10> width
			x = width - @popupWidth - 10

		##| because of table context menu popup had to comment
		# if @y + @popupHeight + 10 > height
		# 	@y = height - @popupHeight - 10


		window.popupMenuHolder.css
			left:  x
			top:   @y
			#width: @popupWidth

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

		# @property [Array] linkObjects to store all the objects of link
		@linkObjects = []

		##|
		##| if the 2nd parameter is an event, use that event to open the popup
		if @x? and @x and @x.currentTarget? and @x.currentTarget
			values = GlobalValueManager.GetCoordsFromEvent @x
			@x.stopPropagation()
			@x.preventDefault()
			@x = values.x
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
		#window.popupMenuHolder.removeClass("multicol")
		@setMultiColumn 1
		html = "<li class='title'>" + @title + "</li>"
		window.popupMenuHolder.html(html)

		setTimeout () ->
			window.popupMenuHolder.show()
		, 10


		globalKeyboardEvents.once "global_mouse_down", @onGlobalMouseDown
		globalKeyboardEvents.once "esc", @onGlobalEscKey

		##|
		##|  Setup with default sizeing
		@resize @popupWidth
		@colCount  = 1
		@menuItems = {}
		@menuData  = {}

	## -------------------------------------------------------------------------------------------------------------
	## close the window after the mouse drifts away from it
	##
	closeTimer: () =>
		window.popupMenuHolder.hide()
		window.popupMenuVisible = false
		window.popupMenuTimer = 0

		globalKeyboardEvents.off "global_mouse_down", @onGlobalMouseDown
		globalKeyboardEvents.off "esc", @onGlobalEscKey
		false;

	## -------------------------------------------------------------------------------------------------------------
	## Enable multiple columns in the context menu
	##
	## @param [Integer] colCount the number of columns
	##
	setMultiColumn: (@colCount, colWidth) =>
		if !colWidth? then colWidth = @popupWidth
		@resize (@colCount*colWidth)
		window.popupMenuHolder.addClass("multicol")
		$(".multicol").css "columnCount", @colCount
		$(window.popupMenuHolder).find(".title").css "columnSpan", "all"
		console.log "FIND:", $(".title")


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
			className = "popupMenuItem"

		linkObject = new PopupMenuItem(name,className,id)
		@linkObjects.push linkObject
		link = linkObject.link

		if @colCount > 0
			link.addClass "multicol"

		link.on "click", (e) =>
			e.preventDefault()
			e.stopPropagation()

			##|
			##|  Close popup
			@closeTimer()

			##|  Lookup the element selected, make a callback
			dataId = $(e.target).attr("data-id")
			if dataId
				@menuItems[dataId](e, @menuData[dataId])

			true

		@resize @popupWidth
		linkObject

	onGlobalEscKey: (e)=>
		# console.log "POPUP MENU, onGlobalEscKey", window.popupMenuVisible
		@closeTimer()
		return false

	onGlobalMouseDown: (e)=>
		console.log "POPUP MENU, onGlobalMouseDown", window.popupMenuVisible
		if !window.popupMenuVisible then return false
		setTimeout @closeTimer, 200
		return false

