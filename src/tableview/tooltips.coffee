##|
##|  Implement tooltips on elements
##|
##|  Call the function "setupSimpleTooltips" to activate.   It can be called many
##|  times.  It will find elements with the attribe tooltip='simple' and will
##|  use data-title as the text for the tooltip.
##|

window.globalHoverTimer   = 0
window.globalHoverElement = 0
window.elSimpleTooltip    = 0
window.elSimpleIndicator  = 0

initializeSimpleTooltips = () ->

	##|
	##|  The first time simple tooltips are needed,
	##|  add the holder elements to the body and create fast reference pointers to them.
	##|

	$("body").append $ "<i>",
		class:	"fa fa-lightbulb-o"
		id:     "simpleTooltipIndicator"

	$("body").append $ "<div>",
		class:	"simpleTooltip"
		id:     "simpleTooltip"

	window.elSimpleTooltip = $("#simpleTooltip")
	window.elSimpleIndicator = $("#simpleTooltipIndicator")

##|
##|  A timer that is activated on mouseover from a tooltip enabled element
##|
simpleTooltipTimer = ()->
	title = window.globalHoverElement.attr("data-title")
	pos   = window.globalHoverElement.position()

	window.elSimpleTooltip.html(title).show()

	x = pos.left + (window.globalHoverElement.width() / 2) - (window.elSimpleTooltip.width() / 2)
	y = pos.top  - 10 - window.globalHoverElement.height() - 40

	if (x < 0) then x = 0
	if (x + window.globalHoverElement.width() > $(window).width())
		x = $(window).width - 10 - window.globalHoverElement.width()

	window.elSimpleTooltip.show().css
		left: x
		top : y

setupSimpleTooltips = () ->

	if window.elSimpleTooltip == 0
		initializeSimpleTooltips()

	$("body").find('[tooltip="simple"]').each (idx, el) ->

		$el = $(el)
		tooltipID = $el.attr("data-id-tooltip");
		if ! tooltipID
			tooltipID = GlobalValueManager.NextGlobalID()
			$el.attr("data-id-tooltip", tooltipID)

			$el.on 'mouseover', (e) ->
				window.elSimpleIndicator.show()
				if window.globalHoverTimer then clearTimeout window.globalHoverTimer
				window.globalHoverElement = $(e.target)
				window.globalHoverTimer   = setTimeout simpleTooltipTimer, 1000
				true

			$el.on 'mouseout', (e) ->
				window.elSimpleIndicator.hide()
				if window.globalHoverTimer then clearTimeout window.globalHoverTimer
				window.elSimpleTooltip.hide()
				true

