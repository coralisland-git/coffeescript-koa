## -------------------------------------------------------------------------------------------------------------
## Universal class to translate from one value to another
## that is designed to be human readdable
##
##
## create a namespace to export our public methods
root = exports ? this
root.DataFormatter = class DataFormatter

	# @property [Object] formats
	formats: {}

	## -------------------------------------------------------------------------------------------------------------
	## given a string, return number
	##
	## @param [String] data data to be converted to number
	## @return [Float] result equalent version of string in fload
	@getNumber: (data) =>
		if !data? then return 0
		if typeof data == "number" then return data
		if m = data.toString().match(/(\d+)\s*%/)
			console.log "M1=", m[1]
			return parseFloat(m[1])/100.0

		result = data.toString().replace /[^0-9\.\-]/g, ""
		result = parseFloat result
		if isNaN(result) then return 0
		return result

	## -------------------------------------------------------------------------------------------------------------
	## Given a date in a human readable form, parse it and return the Moment
	## object (see momentjs) that represents the date/time.
	##
	## @param [string] date The date string to parse
	## @note returns null if the date is invalid
	## @return [Moment] moment object
	##
	@getMoment: (data) =>

		try

			if !data? then return null

			if data? and data._isAMomentObject? and data._isAMomentObject
				return data

			if typeof data == "object" and data.getTime?
				return moment(data)

			if data.match /\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d/
				return moment(data, "YYYY-MM-DD HH:mm:ss")

			if data.match /\d\d\d\d-\d\d-\d\d/
				return moment(data, "YYYY-MM-DD")

			if data.match /\d\d\d\d\.\d\d\.\d\d \d\d:\d\d:\d\d/
				return moment(data, "YYYY-MM-DD HH:mm:ss")

			if data.match /\d\d\d\d\.\d\d\.\d\d/
				return moment(data, "YYYY-MM-DD")

			if data.match /\d\d-\d\d-\d\d\d\d \d\d:\d\d:\d\d/
				return moment(data, "MM-DD-YYYY HH:mm:ss")

			if data.match /\d\d-\d\d-\d\d\d\d/
				return moment(data, "MM-DD-YYYY")

			if data.match /\d\d\/\d\d\/\d\d\d\d \d\d:\d\d:\d\d/
				return moment(data, "MM/DD/YYYY HH:mm:ss")

			if data.match /\d\d\/\d\d\/\d\d\d\d/
				return moment(data, "MM/DD/YYYY")

			if typeof data == "object" and data['$date']?
				return moment(new Date(data['$date']))

		catch e

			console.log "Unable to get date from [", data, "]"

		return null;

	## -------------------------------------------------------------------------------------------------------------
	## function to register the data formatter class
	##
	## @param [DataFormatterType] formattingClass
	## @return null
	##
	register: (formattingClass) =>

		@formats[formattingClass.name] = formattingClass

	## -------------------------------------------------------------------------------------------------------------
	## function to get the data formatter from registered formatter
	##
	## @param [String] dataTpe data type name of the desired formatter class
	## @note fires error if formatter not found
	## @return DataFormatterType
	##
	getFormatter: (dataType) =>

		if !@formats[dataType]
			console.log "Registered types:", @formats
			throw new Error("Invalid type: " + dataType)

		return @formats[dataType]

	## -------------------------------------------------------------------------------------------------------------
	## Format some data based on the type and
	## return just the formatted value, not the style or other details.
	##
	## @param [String] dataType data type name for which formatter is running
	## @param [Object] data data to be formatted
	## @param [Object] options additional options to apply formatting
	## @param [String] path the current path at which the formatter is running
	## @return [Object] value formatted data using data type formatter
	##
	formatData: (dataType, data, options, path) =>

		if !@formats[dataType]?
			console.log "Registered types:", @formats
			return "Invalid type [#{dataType}]"

		value = @formats[dataType].format data, options, path

	## -------------------------------------------------------------------------------------------------------------
	## UnFormat some data based on the type and
	## return just the unformatted value, not the style or other details.
	##
	## @param [String] dataType data type name for which formatter is running
	## @param [Object] data data to be formatted
	## @param [Object] options additional options to apply formatting
	## @param [String] path the current path at which the formatter is running
	## @return [Object] value unformatted data using data type formatter
	##
	unformatData: (dataType, data, options, path) =>

		if !@formats[dataType]? then return "Invalid type [#{dataType}]"
		value = @formats[dataType].unformat data, options, path

	## -------------------------------------------------------------------------------------------------------------
	## constructor
	##
	##
	constructor: () ->
