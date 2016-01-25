##|
##| Global values manager, providers a number of static functions that are designed
##| to help in general purpose ways.   This is required by all components in the folder
##|


##|
##|  Global variables

class GlobalValueManager

    @globalCellID    : 0
    @globalData      : {}


    ##| Returns a sequential number unique across the app.   Used to
    ##| generate id numbers for new html elements.
    ##|
    ##| @example
    ##|    id = GlobalValueManager.NextGlobalID()
    ##|
    @NextGlobalID = () ->
        gid = GlobalValueManager.globalCellID++
        return gid

    ##|
    ##| Set a global value given some unique key
    ##|
    ##| @param [mixed] gid The reference key
    ##| @param [mixed] obj The value to store
    ##|
    ##| @example
    ##|    GlobalValueManager.SetGlobal "key", "value"
    ##|
    @SetGlobal = (gid, obj) ->
        GlobalValueManager.globalData[gid] = obj
        return gid

    ##|
    ##| Get a global value given some unique key.  Returns undefined
    ##| if nothing has been saved with that key.
    ##|
    ##| @param [mixed] gid The reference key
    ##|
    ##| @example
    ##|    GlobalValueManager.GetGlobal "key"
    ##|
    @GetGlobal = (gid) ->
        return GlobalValueManager.globalData[gid];


    ##|
    ##|  Returns the HTML required to display a loading spinner.
    ##|
    @GetLoading = () ->
        return "<i class='fa fa-3x fa-asterisk fa-spin'></i>"

    ##|
    ##|  Given an event object such as that received on a mouse over, find the
    ##|  actual coordinates which may be adjusted depending on scroll position
    ##|  and browser type.
    ##|
    ##|  @param [Event] e the event object
    ##|  @return [Object] returns an object with x/y defined
    ##|
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


    ##|
    ##| Get a number from one of the values
    ##| where we look at each value and if defined use
    ##| that, but if not, use the next one
    ##|
    ##| @param [Number] a The first value to check
    ##| @param [Number] b The second value to check
    ##| @param [Number] c The third value to check
    ##| @param [Number] d The forth value to check
    ##|
    ##| @example
    ##|    price = GlobalValueManager.GetNumber possiblePrice1, possiblePrice2
    ##|
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

    ##|
    ##| Given a date in a human readable form, parse it and return the Moment
    ##| object (see momentjs) that represents the date/time.
    ##|
    ##| @param [string] date The date string to parse
    ##|
    ##| @note returns null if the date is invalid
    ##|
    @GetMoment = (date) ->

        if date == null
            return null;

        if typeof date != "string"
            return null;

        if date.match /\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d/
            return moment(date, "YYYY-MM-DD HH:mm:ss")

        if date.match /\d\d\d\d.\d\d.\d\d/
            return moment(date, "YYYY-MM-DD")

        if date.match /\d\d-\d\d-\d\d\d\d/
            return moment(date, "MM-DD-YYYY")

        return null;

    ##|
    ##| Days ago formatting
    @DaysAgo = (stamp) ->

        m = GlobalValueManager.GetMoment(stamp)
        if m == null then return 0

        age = moment().diff(stamp)
        age = Math.trunc(age / 86400000)

        if age == 1 then return "1 day"
        return age + " days"


    ##|
    ##| Given a date in a Moment object, return an HTML display
    ##| This includes a span with the age of the date such as 32 days
    ##|
    ##| @param [Moment] date The date object
    ##|
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


    ##|
    ##|  Give some text, returns a title version, for example
    ##|  give "user_name" it returns User Name
    ##|
    @Ucwords = (str) ->
        return (str + '').replace /^([a-z\u00E0-\u00FC])|\s+([a-z\u00E0-\u00FC])/g, ($1) ->
            return $1.toUpperCase();

    ##|
    ##|  Trigger an event and pass data to that event.   When combined with the
    ##|  "Watch" function this is a simple form of "pub sub" within the global
    ##|  app scope.
    @Trigger = (eventName, dataObject) ->
        $("body").trigger eventName, dataObject
        true

    ##|
    ##|  See Trigger for information on Watch/Trigger for global pub sub events.
    @Watch = (eventName, delegate) ->
        $("body").on eventName, delegate
        true


