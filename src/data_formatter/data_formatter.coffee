##|
##|  Universal class to translate from one value to another that
##|  is designed to be human readable
##|

class DataFormatter

	##|
	##| Output:  Suggested width of the data to display in pixels
	formats: {}

	##|
	##|  Given a string, return a number
	@getNumber: (data) =>
		if !data? then return 0
		if typeof data == "number" then return data
		result = data.toString().replace /[^0-9\.\-]/g, ""
		result = parseFloat result

	##|
	##| Given a date in a human readable form, parse it and return the Moment
	##| object (see momentjs) that represents the date/time.
	##|
	##| @param [string] date The date string to parse
	##|
	##| @note returns null if the date is invalid
	##|
	@getMoment: (data) =>

		if !data? then return null

		if data? and data._isAMomentObject? and data._isAMomentObject
			return data

		if typeof date != "string"
			return moment(data)

		if date.match /\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d/
			return moment(date, "YYYY-MM-DD HH:mm:ss")

		if date.match /\d\d\d\d.\d\d.\d\d/
			return moment(date, "YYYY-MM-DD")

		if date.match /\d\d-\d\d-\d\d\d\d/
			return moment(date, "MM-DD-YYYY")

		return null;

	register: (formattingClass) =>

		@formats[formattingClass.name] = formattingClass


	##|
	##|  Format some data based on the type and
	##|  return just the formatted value, not the style or other details.
	##|
	formatData: (dataType, data, options, path) =>

		if !@formats[dataType]?
			console.log "Registered types:", @formats
			return "Invalid type [#{dataType}]"

		value = @formats[dataType].format data, options, path

	##|
	##|  Convert visual data into a storable raw format
	unformatData: (dataType, data, options, path) =>

		if !@formats[dataType]? then return "Invalid type [#{dataType}]"
		value = @formats[dataType].unformat data, options, path


	constructor: () ->

