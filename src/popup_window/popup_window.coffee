##|
##|  Popup window widget
##|
##|  This class creates a popup window That has a title and is dragable.
##|
##|  @example
##|      popup = new PoupWindow(title, x, y)
##|


class PopupWindow

	popupWidth:  600
	popupHeight: 400
	isVisible:   false

	##|
	##|  Returns the available height for the body element
	getBodyHeight: () =>
		h = @popupHeight
		h -= 1 ## top padding
		h -= 1 ## bottom padding
		h -= @windowTitle.height()
		return h

	##|
	##|  Update the display, must be called if the height of the body content changes
	##|
	update: () =>
		@myScroll.refresh();

	open: () =>
		setTimeout () =>
			@update()
		, 20
		@popupWindowHolder.show()
		@isVisible = true
		true

	close: (e) =>
		if typeof e != "undefined" and e != null
			e.preventDefault()
			e.stopPropagation()

		@popupWindowHolder.hide()
		@isVisible = false
		false

	destroy: () =>

		@close()
		@popupWindowHolder.remove()
		true

	center: () =>
		width  = $(window).width()
		height = $(window).height()
		@x = (width - @popupWidth) / 2
		@y = (height - @popupHeight) / 2
		@popupWindowHolder.css
			left:   @x
			top:    @y

	##|
	##|  Resize the window to a new size
	##|
	##|  @param popupWidth [int] the new width
	##|  @param popupHeight [int] the new height
	##|
	resize: (@popupWidth, @popupHeight) =>

		width  = $(window).width()
		height = $(window).height()

		if @x == 0 and @y == 0
			@center()

		if @x < 0
			@x = 0

		if @y < 0
			@y = 0

		if @x + @popupWidth + 10> width
			@x = width - @popupWidth - 10

		if @y + @popupHeight + 10 > height
			@y = height - @popupHeight - 10

		@popupWindowHolder.css
			left:   @x
			top:    @y
			width:  @popupWidth
			height: @popupHeight

		@windowWrapper.css
			left: 0
			top: 4
			width: @popupWidth
			height: @popupHeight - 26 - 5

		setTimeout () =>
			@myScroll.refresh()
		, 100

		@popupWindowHolder.show()
		@isVisible = true

		true

	##|
	##|  Check to see if there is a saved location and move to it
	checkSavedLocation: () =>

		location = user.get "PopupLocation_#{@title}", 0
		if location != 0
			@x = location.x
			@y = location.y

	##|
	##|  Create a new window
	##|  @param title [stirng] the window title
	##|  @param x [int] upper left corner
	##|  @param y [int] top left corner
	##|
	constructor: (@title, @x, @y) ->

		if typeof @x == "undefined" or @x < 0 then @x = 0
		if typeof @y == "undefined" or @y < 0 then @y = 0
		id   = GlobalValueManager.NextGlobalID()
		html = $ "<div />",
			class: "PopupWindow"
			id:    "popup#{id}"

		@popupWindowHolder = $(html)
		$("body").append @popupWindowHolder

		##|
		##| Title div
		@windowTitle = $ "<div />",
			class: "title"
			id: "popuptitle#{id}"
			dragable: "true"
		.html @title
		@popupWindowHolder.append @windowTitle

		@windowClose = $ "<div />",
			class: "closebutton"
			id: "windowclose"
		.html "X"
		@windowTitle.append @windowClose
		@windowClose.on "click", () =>
			@close()

		##|
		##| Body div with IScroll wrapper
		@windowScroll  = $ "<div />",
			class: "scrollcontent"

		@windowWrapper = $ "<div />",
			id: "windowwrapper#{id}"
			class: "scrollable"
		.append @windowScroll

		@windowBodyWrapperTop  = $ "<div />",
			class: "windowbody"
		.css
			position: "absolute"
			top:      @windowTitle.height() + 2
			left:     0
			right:    0
			bottom:   0
		.append @windowWrapper

		@popupWindowHolder.append @windowBodyWrapperTop

		##|
		##|  Setup a scroll area within the body
		@myScroll = new IScroll "#windowwrapper#{id}",
			mouseWheel: true
			scrollbars: true
			bounce: false
			resizeScrollbars: false

		@dragabilly = new Draggabilly "#popup#{id}",
			handle: "#popuptitle#{id}"

		@dragabilly.on "dragStart", (e) =>
			@popupWindowHolder.css "opacity", "0.5"
			return false

		@dragabilly.on "dragMove", (e) =>
			x = @dragabilly.position.x
			y = @dragabilly.position.y
			w = $(window).width()
			h = $(window).height()
			if x + 50 > w then @dragabilly.position.x = w - 50
			if y + 50 > h then @dragabilly.position.y = h - 50
			if x < -50 then @dragabilly.position.x = -50
			if y < 0 then @dragabilly.position.y = 0

			user.set "PopupLocation_#{@title}",
				x: x
				y: y

			return false

		@dragabilly.on "dragStart", (e) =>
			@popupWindowHolder.css "opacity", "0.5"
			return false

		@dragabilly.on "dragEnd", (e) =>
			@popupWindowHolder.css "opacity", "0.95"
			return false


		##|
		##|  Setup with default sizeing
		@resize 600, 400
		@colCount  = 1
		@menuItems = {}
		@menuData  = {}
