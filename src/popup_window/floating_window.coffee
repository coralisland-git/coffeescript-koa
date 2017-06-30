
class FloatingWindow

	width  : 300
	height : 200
	parent : null
	top    : 0
	left   : 0

	##|
	##|  The actual element isn't created until show() is called
	##|  and it's hidden on hide.   It's destroyed on close()
	##|
	constructor: (x, y, w, h, parentHolder, options)->

		if options? then $.extend this, options

		if w? then @width  = w
		if h? then @height = h
		if y? then @top    = y
		if x? then @left   = x

		if parentHolder?
			@parent = $(parentHolder)
		else
			@parent = $("body")

		@floatingWin = null

	internalCreateElement: ()=>

		if @floatingWin? then return

		# console.log "FloatingWindow Creating window x=#{@left}, y=#{@top}, w=#{@width}, h=#{@height}"
		# console.log "global.temp1=", this
		# window.temp1 = this

		@floatingWin = new WidgetTag "div", "floatingWindow"
		@floatingWin.move(@left, @top, @width, @height)
		# @floatingWin.appendTo @parent
		@floatingWin.appendTo $("body")
		@floatingWin.hide()

		@elHolder = @floatingWin.addDiv "floatingWinBody"
		@elHolder.setAbsolute()
		@elHolder.move(0, 0, @width, @height)

		true

	getBodyWidget: ()=>
		@internalCreateElement()
		return @elHolder

	html: (html)=>
		@getBodyWidget().html html

	show: ()=>
		@internalCreateElement()
		@floatingWin.show()

	hide: ()=>
		if @floatingWin?
			@floatingWin.hide()

	moveTo: (x, y)=>
		@top  = y
		@left = x
		if @floatingWin?
			@floatingWin.move(@left, @top, @width, @height)
		true

	setSize: (w, h)=>
		@width = w
		@height = h
		if @floatingWin?
			@floatingWin.move(@left, @top, @width, @height)
		true

	##|
	##|  Removes the entire floating window and all traces of it.
	##|
	destroy: ()=>
		@floatingWin.destroy()
		delete @floatingWin

	##|
	##|  move to the top right corner with some padding
	##|
	dockTopRight: (newWidth = 300, newHeight = 120)=>

		w = $(window).width()
		h = $(window).height()
		@setSize newWidth, newHeight
		@moveTo (w-newWidth-20), 20
		true


