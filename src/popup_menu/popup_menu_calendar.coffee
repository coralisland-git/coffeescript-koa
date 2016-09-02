## -------------------------------------------------------------------------------------------------------------
## class PopupMenuCalendar to handle calendar in popup
## This class creates a popup window that is managed like a list.  It's used
## mainly for context menus.   Only one popup menu can be shown at a time.
##
## @example popup = new PopupMenuCalendar value, x, y
##
class PopupMenuCalendar

	# @property [Boolean] autoClose, weather after date selection it should close or not
	autoClose: true

	## -------------------------------------------------------------------------------------------------------------
	## function to call when date is changed
	##
	## @event onChange
	## @param [Date] newDate the newly selected date
	##
	onChange: (newDate, newDateString) =>
		console.log "Unhandled onChange in PopupMenuCalendar for date=#{newDate}", "datestring = #{newDateString}"

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
			@element = $ @x.currentTarget
			@x.stopPropagation()
			@x.preventDefault()
		else
			##| create element(dummy) to handle the flatpickr
			@hiddenElementId = GlobalValueManager.NextGlobalID()
			@element = $('<input />',
				style: 'display: none'
				id: @hiddenElementId
			).after('body')

		@theMoment = GlobalValueManager.GetMoment(@value)
		if typeof @theMoment == "undefined" or @theMoment == null
			@showingMoment = moment()
		else
			@showingMoment = moment(@theMoment)

		@flatPickr = new flatpickr @element[0],
			defaultDate: @showingMoment.format('YYYY-MM-DD')

		@bindEvents()

		##| manually open flatpickr
		@flatPickr.open()

	bindEvents: () =>
		##| close pickr after date has been changed and emit event
		@flatPickr.config.onChange = (dateObject, dateString) =>
			@onChange dateObject, dateString
			if @autoClose
				@element[0]._flatpickr.close()

		## -------------------------------------------------------------------------------------------------------------
		## setup and event to monitor all clicks, if someone clicks
		## while the popup menu is open, close it.
		##
		$(document).one 'click', (e) =>
			@flatPickr.close()

		## -------------------------------------------------------------------------------------------------------------
		## close the popup with escape key
		##
		$(document).one 'keypress', (e) =>
			if e.keyCode is 27
				@flatPickr.close()

	## -------------------------------------------------------------------------------------------------------------
	## destroy handler to destroy the picker
	##
	##
	destroy: () =>
		##| if its dummy input created by class itself we remove it.
		@element[0]._flatpickr.destroy()
		if @hiddenElementId
			@element.remove()
