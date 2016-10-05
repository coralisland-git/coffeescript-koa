
class FloatingWindow

	constructor: (x, y, @w, @h, parent)->

		@el = $ "<div class='floatingWindow'/>"
		@el.css
			position : "absolute"
			left     : x
			top      : y
			width    : @w
			height   : @h
			zIndex   : 1503432
			border   : "1px solid blue"
			overflow : "hidden"
			display  : "none"

		# console.log "FloatingWindow Creating window x=#{x}, y=#{y}, w=#{@w}, h=#{@h}"

		if parent?
			$(parent).append @el
		else
			$(document.body).append @el

