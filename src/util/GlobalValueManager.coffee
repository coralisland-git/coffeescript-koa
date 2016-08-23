l = console.log

## global date format for utc date
reDateUtc = /\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d.\d\d\dZ/

## -------------------------------------------------------------------------------------------------------------
## class GlobalValueManager
## providers a number of static functions that are designed to help in general purpose ways.
## this is required by all components in the folder
##
##
class GlobalValueManager

	# @property [Integer] globalCellID
    @globalCellID    : 0

	# @property [Object] globalData
    @globalData      : {}

	## -------------------------------------------------------------------------------------------------------------
	## returns a sequential number unique across the app. used to generate id numbers
	## for new html elements
	##
	## @return [Integer] gid the new id for the html
	##
    @NextGlobalID = () ->
        gid = GlobalValueManager.globalCellID++
        return gid

	## -------------------------------------------------------------------------------------------------------------
	## set a global value given some unique key
	##
	## @param [mixed] gid the reference key
	## @param [mixed] obj the value to store
	## @return [Integer] gid the reference key
	##
    @SetGlobal = (gid, obj) ->
        GlobalValueManager.globalData[gid] = obj
        return gid

	## -------------------------------------------------------------------------------------------------------------
	## Get a global value given some unique key. returns undefined
	## if nothing has been saved with that key.
	##
	## @param [mixed] gid the reference key
	## @return [mixed] the data saved at reference key
	##
    @GetGlobal = (gid) ->
        return GlobalValueManager.globalData[gid];

	## -------------------------------------------------------------------------------------------------------------
	## returns the html required to display a loading spinner.
	##
	## @return [String] the html for spinner
	##
    @GetLoading = () ->
        return "<i class='fa fa-3x fa-asterisk fa-spin'></i>"

	## -------------------------------------------------------------------------------------------------------------
	## given an event object such as that received on a moouse over, find the
	## actual coordinates which may be adjusted depending on scroll position
	## and browser type.
	##
	## @param [Event] e the event Object
	## @return [Object] returns an object with x/y defined
	##
    @GetCoordsFromEvent = (e) ->

        clickX = 0
        clickY = 0

        if (e.clientX || e.clientY) && document.body && document.body.scrollLeft != null
            clickX = e.clientX + document.body.scrollLeft
            clickY = e.clientY + document.body.scrollTop

        if (e.clientX || e.clientY) && document.compatMode == 'CSS1Compat' && document.documentElement && document.documentElement.scrollLeft != null
            clickX = e.clientX + document.documentElement.scrollLeft
            clickY = e.clientY + document.documentElement.scrollTop

        if e.pageX || e.pageY
            clickX = e.pageX
            clickY = e.pageY

        values = {}
        values.x = clickX
        values.y = clickY
        return values

	## -------------------------------------------------------------------------------------------------------------
	## Get a number from one of the values
	## where we look at each value and if defined use
	## that, but if not, use the next one
	##
	## @example
    ##    price = GlobalValueManager.GetNumber possiblePrice1, possiblePrice2
	## @param [Integer] a the first value to check
    ## @param [Integer] b The second value to check
    ## @param [Integer] c The third value to check
    ## @param [Integer] d The forth value to check
    ##
    @GetNumber = (a, b, c, d) ->

        if typeof a != "undefined" and a != null
            value = parseInt(a)
            if value then return value

        if typeof b != "undefined" and  b != null
            value = parseInt(b)
            if value then return value

        if typeof c != "undefined" and c != null
            value = parseInt(c)
            if value then return value

        if typeof d != "undefined" and d != null
            value = parseInt(d)
            if value then return value

        return 0

	## -------------------------------------------------------------------------------------------------------------
	## Given a date in a human readable form, parse it and return the Moment
	## object (see momentjs) that represents the date/time.
	##
	## @param [String] date the date string to parse
	## @return [Moment] return moment object and if invalid date then null
	##
    @GetMoment = (date) ->

        try

            if date == null
                return null;

            if date? and typeof date == "object" and date.getTime?
                return moment(date)

            if typeof date != "string"
                return null;


            if reDateUtc.test date
                return moment(date)

            date = date.replace "T", " "

            if date.match /\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d/
                return moment(date, "YYYY-MM-DD HH:mm:ss")

            if date.match /\d\d\d\d.\d\d.\d\d/
                return moment(date, "YYYY-MM-DD")

            if date.match /\d\d-\d\d-\d\d\d\d/
                return moment(date, "MM-DD-YYYY")

        catch e

            console.log "Unable to get date from:", e

        return null;

	## -------------------------------------------------------------------------------------------------------------
	## Days ago formatting
	##
	## @param [String] stamp date string
	## @return [String] return the days ago formatted string
	##
    @DaysAgo = (stamp) ->

        m = GlobalValueManager.GetMoment(stamp)
        if m == null then return 0

        age = moment().diff(stamp)
        age = Math.trunc(age / 86400000)

        if age == 1 then return "1 day"
        return age + " days"

	## -------------------------------------------------------------------------------------------------------------
	## Given a date in a Moment object, return an html display
	## This includes a span with the age of the date such as 32 days
	##
	## @param [Moment] date the date object
	## @return [String] html span tag html with age in that
	##
    @DateFormat = (stamp) ->

        if stamp == null
            if val then return val
            return "&mdash;"

        html = "<span class='fdate'>" + stamp.format("MM/DD/YYYY") + "</span>"

        age = moment().diff(stamp)
        age = age / 86400000

        if (age < 401)
            age = numeral(age).format("#") + " d"
        else if (age < 365 * 2)
            age = numeral(age / 30.5).format("#") + " mn"
        else
            age = numeral(age / 365).format("#.#") + " yrs"

        html += "<span class='fage'>" + age + "</span>"

	## -------------------------------------------------------------------------------------------------------------
	## given a date in a Moment object, return an html display
	## this includes a span with age of the date such as 32 days
	##
	## @param [Moment] date the date object
	## @return [String] html the span html string
	##
    @DateTimeFormat = (stamp) ->

        if stamp == null
            return "&mdash;"

        html = "<span class='fdate'>" + stamp.format("dddd, MMMM Do YYYY, h:mm:ss a") + "</span>"

        age = moment().diff(stamp)
        age = age / 86400000

        if (age < 1)
            hrs = age * 24
            if hrs > 3
                age = numeral(hrs).format("#") + " hours"
            else
                min = age * (24 * 60)
                age = numeral(min).format("#") + " minutes"
        else if (age < 401)
            age = numeral(age).format("#") + " days"
        else if (age < 365 * 2)
            age = numeral(age / 30.5).format("#") + " months"
        else
            age = numeral(age / 365).format("#.#") + " years"

        html += "<span class='fage'>" + age + "</span>"

	## -------------------------------------------------------------------------------------------------------------
	## give some text, returns a title version, for example
	## give "user_name" it returns User Name
	##
	## @param [String] str the string in which title will be fixed
	## @return [String] fixed title case string
	##
    @Ucwords = (str) ->
        return (str + '').replace /^([a-z\u00E0-\u00FC])|\s+([a-z\u00E0-\u00FC])/g, ($1) ->
            return $1.toUpperCase();

	## -------------------------------------------------------------------------------------------------------------
	## Trigger an event and pass data to that event. When combined with the
	## "Watch" function this is a simple form of "pub sub" within the global
	## app scope.
	##
	## @param [String] eventName name of the event
	## @param [Object] dataObject
	## @return [Boolean]
	##
    @Trigger = (eventName, dataObject) ->
        $("body").trigger eventName, dataObject
        true

	## -------------------------------------------------------------------------------------------------------------
	## see Trigger for information on Watch/Trigger for global pub sub events
	##
	@Watch = (eventName, delegate) ->
        $("body").on eventName, delegate
        true
