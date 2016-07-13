window.popupCalendarVisible = false
window.popupCalendarHolder  = null


## -------------------------------------------------------------------------------------------------------------
## class PopupMenuCalendar to handle calendar in popup
## This class creates a popup window that is managed like a list.  It's used
## mainly for context menus.   Only one popup menu can be shown at a time.
##
## @example popup = new PopupMenuCalendar value, x, y
##
class PopupMenuCalendar

	# @property [Integer] popupWidth the width of the popup default 350
	popupWidth:  350

	# @property [Integer] popupHeight the height of the popup default 398
	popupHeight: 350 + 24 + 24

	## -------------------------------------------------------------------------------------------------------------
	## function to call when date is changed
	##
	## @event onChange
	## @param [Date] newDate the newly selected date
	##
	onChange: (newDate) =>
		console.log "Unhandled onChange in PopupMenuCalendar for date=", newDate

	## -------------------------------------------------------------------------------------------------------------
	## change the width of the popup menu
	##
	## @param [Integer] popupWidth new width of popup
	##
	resize: (@popupWidth) =>

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

		if @y + @popupHeight + 10 > height
			@y = height - @popupHeight - 10

		window.popupCalendarHolder.css
			left:   @x
			top:    @y
			width:  @popupWidth
			height: @popupHeight

		window.popupCalendarHolder.show()

		true

	## -------------------------------------------------------------------------------------------------------------
	## constructor create new popup
	##
	## @param [String] value The current value if set
	## @param [Integer] x the adjusted X location to open
	## @param [Integer] y the adjusted Y location to open
	##
	constructor: (@value, @x, @y) ->

		##|
		##| if the 2nd parameter is an event, use that event to open the popup
		if @x? and @x and @x.currentTarget? and @x.currentTarget
			values = GlobalValueManager.GetCoordsFromEvent @x
			@x.stopPropagation()
			@x.preventDefault()
			@x = values.x - 150
			@y = values.y - 10

		@title = "Select Date"
		@theMoment = GlobalValueManager.GetMoment(@value)
		if typeof @theMoment == "undefined" or @theMoment == null
			@showingMoment = moment()
		else
			@showingMoment = moment(@theMoment)

		if @x < 0 then @x = 0
		if @y < 0 then @y = 0

		$(".PopupMenuCal").remove()

		window.popupCalendarVisible = false
		id   = GlobalValueManager.NextGlobalID()
		html = $ "<div />",
			class: "PopupMenuCal"
			id:    "popup#{id}"

		window.popupCalendarHolder = $(html)
		window.popupMenuTimer  = 0
		$("body").append window.popupCalendarHolder

		$(window.popupCalendarHolder).on "mouseout", (e) =>
			if window.popupCalendarVisible
				if window.popupMenuTimer then clearTimeout window.popupMenuTimer
				window.popupMenuTimer = setTimeout @closeTimer, 1750
				false
			true

		$(window.popupCalendarHolder).on "mouseover", (e) =>
			if window.popupCalendarVisible
				if window.popupMenuTimer then clearTimeout window.popupMenuTimer
				window.popupMenuTimer = 0
			true

		@setupMonth()

		window.popupCalendarVisible = true
		@recalcDays()
		@resize @popupWidth

		##|
		##|  Setup with default sizeing
		@menuItems = {}
		@menuData  = {}

	## -------------------------------------------------------------------------------------------------------------
	## close the window after the mouse drifts away from it
	##
	## @return [Boolean]
	##
	closeTimer: () =>
		console.log "Popup Hide"
		if typeof window.popupCalendarHolder != "undefined" and window.popupCalendarHolder != null
			window.popupCalendarHolder.remove()
			window.popupCalendarHolder = null

		window.popupCalendarVisible = false
		window.popupMenuTimer = 0
		false;

	## -------------------------------------------------------------------------------------------------------------
	## calculate and update the html based on the dates
	##
	recalcDays: () =>

		today = moment()
		todayOfYear = today.dayOfYear()

		now = moment(@showingMoment)
		currentMonth = now.month()
		currentYear  = now.year()
		currentDay   = now.date()

		selectedDayOfYear = -1
		if typeof @theMoment != "undefined" and @theMoment != null
			selectedDayOfYear = @theMoment.dayOfYear()
			selectedYear = @theMoment.year()

		$("#calTitle").html now.format("MMM, YYYY")

		now = now.subtract(currentDay-1, "days")
		now = now.subtract(now.day(), "days")
		for n in [0..41]

			dayLetter = now.day()
			dayNum    = now.date()
			yearNum   = now.year()
			monthNum  = now.month()

			@elDay[n].html dayNum
			@elDay[n].removeClass "diffMonth"
			@elDay[n].removeClass "today"
			@elDay[n].removeClass "selected"

			if monthNum != currentMonth
				@elDay[n].addClass "diffMonth"

			if now.dayOfYear() == todayOfYear and yearNum == today.year()
				@elDay[n].addClass "today"

			if now.dayOfYear() == selectedDayOfYear and yearNum = selectedYear
				@elDay[n].addClass "selected"

			@elDay[n].attr("date-value", now.format("YYYY-MM-DD"))
			now.add(1, "day")

	## -------------------------------------------------------------------------------------------------------------
	## sets up the month including date and navigation between the months
	##
	setupMonth: () =>

		calTemplate = '''
			<table class='PopupCalendar'>
				<tr><td class='prev' id='calPrevious'> <i class='glyphicon glyphicon-chevron-left'></i> </td>
					<td colspan='5' id='calTitle'> Something </td>
					<td class='next' id='calNext'><i class='glyphicon glyphicon-chevron-right'></i> </td>
				</tr>

				<tr>
				<th class='sun'> Sun </th>
				<th class='mon'> Mon </th>
				<th class='tue'> Tue </th>
				<th class='wed'> Wed </th>
				<th class='thu'> Thu </th>
				<th class='fri'> Fri </th>
				<th class='sat'> Sat </th>
				</tr>

				<tr>
				<td class='sun' id='cal0'> x </td>
				<td class='mon' id='cal1'> x </td>
				<td class='tue' id='cal2'> x </td>
				<td class='wed' id='cal3'> x </td>
				<td class='thu' id='cal4'> x </td>
				<td class='fri' id='cal5'> x </td>
				<td class='sat' id='cal6'> x </td>
				</tr>

				<tr>
				<td class='sun' id='cal7'> x </td>
				<td class='mon' id='cal8'> x </td>
				<td class='tue' id='cal9'> x </td>
				<td class='wed' id='cal10'> x </td>
				<td class='thu' id='cal11'> x </td>
				<td class='fru' id='cal12'> x </td>
				<td class='sat' id='cal13'> x </td>
				</tr>

				<tr>
				<td class='sun' id='cal14'> x </td>
				<td class='mon' id='cal15'> x </td>
				<td class='tue' id='cal16'> x </td>
				<td class='wed' id='cal17'> x </td>
				<td class='thu' id='cal18'> x </td>
				<td class='fru' id='cal19'> x </td>
				<td class='sat' id='cal20'> x </td>
				</tr>

				<tr>
				<td class='sun' id='cal21'> x </td>
				<td class='mon' id='cal22'> x </td>
				<td class='tue' id='cal23'> x </td>
				<td class='wed' id='cal24'> x </td>
				<td class='thu' id='cal25'> x </td>
				<td class='fru' id='cal26'> x </td>
				<td class='sat' id='cal27'> x </td>
				</tr>

				<tr>
				<td class='sun' id='cal28'> x </td>
				<td class='mon' id='cal29'> x </td>
				<td class='tue' id='cal30'> x </td>
				<td class='wed' id='cal31'> x </td>
				<td class='thu' id='cal32'> x </td>
				<td class='fru' id='cal33'> x </td>
				<td class='sat' id='cal34'> x </td>
				</tr>

				<tr>
				<td class='sun' id='cal35'> x </td>
				<td class='mon' id='cal36'> x </td>
				<td class='tue' id='cal37'> x </td>
				<td class='wed' id='cal38'> x </td>
				<td class='thu' id='cal39'> x </td>
				<td class='fru' id='cal40'> x </td>
				<td class='sat' id='cal41'> x </td>
				</tr>

				<tr><td class='message' id='calMessage' colspan=7'></td></tr>

			</table>
		'''

		calCompiled = Handlebars.compile(calTemplate)
		html = calCompiled(this)

		window.popupCalendarHolder.append html

		$("#calNext").bind "click", (e) =>
			e.preventDefault()
			e.stopPropagation()
			@showingMoment.add(1, "month")
			@recalcDays()
			false

		$("#calPrevious").bind "click", (e) =>
			e.preventDefault()
			e.stopPropagation()
			@showingMoment.subtract(1, "month")
			@recalcDays()
			false

		@elDay = {}
		for n in [0..41]
			@elDay[n] = $("#cal#{n}")

			@elDay[n].bind "click toughbegin", (e) =>
				val = $(e.target).attr("date-value")
				@onChange(val)
				@closeTimer()

			@elDay[n].bind "mouseover", (e) =>
				val = $(e.target).attr("date-value")

				m = moment(val)
				age = moment().diff(m)
				age = Math.trunc(age / 86400000)
				if age == -1
					message = "1 day ago"
				else if age == 1
					message = "in 1 day"
				else if age < -1
					message = "in " + Math.abs(age) + " days"
				else
					message = Math.abs(age) + " days ago"


				@calMessage.html val + " (" + message + ")"

			@elDay[n].bind "mouseout", (e) =>
				@calMessage.html ""

		@calMessage = $("#calMessage")




$ ->

	## -------------------------------------------------------------------------------------------------------------
	## setup and event to monitor all clicks, if someone clicks
	## while the popup menu is open, close it.
	##
	$(document).on "click", (e) =>
		if window.popupCalendarVisible
			window.popupCalendarHolder.remove()
			window.popupCalendarVisible = false
		true

	## -------------------------------------------------------------------------------------------------------------
	## close the popup with escape key
	##
	$(document).on "keypress", (e) ->
		if e.keyCode == 27
			if window.popupCalendarVisible
				window.popupCalendarHolder.remove()
				window.popupCalendarVisible = false
			else
				return false
		true
