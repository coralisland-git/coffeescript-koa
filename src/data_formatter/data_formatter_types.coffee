class DataFormatterType

	name:	""
	width:  null

	##|
	##|  Text to add to the css for displaying
	styleFormat: ""

	format: (data, options, path) =>
		return null

	unformat: (data, path) =>
		return null

class DataFormatText extends DataFormatterType

	name: "text"

	format: (data, options, path) =>

		if !data?
			return ""

		return data

	unformat: (data, path) =>

		return data

class DataFormatInt extends DataFormatterType

	name: "int"

	format: (data, options, path) =>
		return numeral(DataFormatter.getNumber data).format("#,###")

	unformat: (data, path) =>
		return DataFormatter.getNumber data

class DataFormatNumber extends DataFormatterType

	name: "number"

	format: (data, options, path) =>
		return numeral(DataFormatter.getNumber data).format("#,###.[##]")

	unformat: (data, path) =>
		return DataFormatter.getNumber data

class DataFormatFloat extends DataFormatterType

	name: "decimal"

	format: (data, options, path) =>
		return numeral(DataFormatter.getNumber data).format("#,###.##")

	unformat: (data, path) =>
		return DataFormatter.getNumber data

class DataFormatCurrency extends DataFormatterType

	name: "money"

	format: (data, options, path) =>
		return numeral(DataFormatter.getNumber data).format('$ #,###.[##]')

	unformat: (data, path) =>
		return DataFormatter.getNumber data

class DataFormatPercent extends DataFormatterType

	name: "percent"

	format: (data, options, path) =>
		return numeral(DataFormatter.getNumber data).format('#,###.[##] %')

	unformat: (data, path) =>
		return DataFormatter.getNumber data/100.0

class DataFormatDate extends DataFormatterType

	name: "date"
	width: 65

	format: (data, options, path) =>
		m = DataFormatter.getMoment data
		if !m? then return ""
		return m.format "MM/DD/YYYY"

	unformat: (data, path) =>
		m = DataFormatter.getMoment data
		if !m? then return ""
		return m.format "YYYY-MM-DD HH:mm:ss"

class DataFormatDateTime extends DataFormatterType

	name: "datetime"
	width: 90

	format: (data, options, path) =>
		m = DataFormatter.getMoment data
		if !m? then return ""
		return m.format "ddd, MMM Do, YYYY h:mm:ss a"

	unformat: (data, path) =>
		m = DataFormatter.getMoment data
		if !m? then return ""
		return m.format "YYYY-MM-DD HH:mm:ss"

class DataFormatDateAge extends DataFormatterType

	name: "age"
	width: 135

	format: (data, options, path) =>
		m = DataFormatter.getMoment data
		if !m? then return "&mdash;"

		html = "<span class='fdate'>" + m.format("MM/DD/YYYY") + "</span>"
		age = moment().diff m
		age = age / 86400000

		if (age < 401)
			age = numeral(age).format("#") + " d"
		else if (age < 365 * 2)
			age = numeral(age / 30.5).format("#") + " mn"
		else
			age = numeral(age / 365).format("#.#") + " yrs"

		html += "<span class='fage'>" + age + "</span>"
		return html

	unformat: (data, path) =>
		m = DataFormatter.getMoment data
		if !m? then return ""
		return m.format "YYYY-MM-DD HH:mm:ss"

class DataFormatEnum extends DataFormatterType

	name: "enum"

	##|
	##| In this case, the options is an array or a comma seperated list of values
	##| data must be one of those values of a numeric index to those values.
	format: (data, @options, path) =>

		if typeof @options == "string"
			@options = @options.split /\s*,\s*/

		if !data?
			return "&mdash;"

		for i, o of @options
			if data == o then return o

		for i, o of @options
			if "#{data}" == "#{i}" then return o

		return "[" + data + "]"

	unformat: (data, path) =>
		return data

class DataFormatDistance extends DataFormatterType

	name: "distance"
	width: 80

	##|
	##| Takes meters in, returns a formatted string
	format: (data, options, path) =>
		val = DataFormatter.getNumber data
		ft = 3280.8 * val
		if (ft < 1000) then return numeral(ft).format("#,###") + " ft."
		mi = 0.621371 * val
		return numeral(mi).format("#,###.##") + " mi.";

	unformat: (data, path) =>
		val = DataFormatter.getNumber(data)
		return val * 3280.8

class DataFormatBoolean extends DataFormatterType

	name: "boolean"
	width: 40

	##|
	##| Takes meters in, returns a formatted string
	format: (data, options, path) =>
		if !data? then return "No"
		if data == null or data == 0 then return "No"
		return "Yes"

	unformat: (data, path) =>
		if !data? then return 0
		if data == null or data == 0 then return 0
		if data == "No" or data == "no" or data == "false" or data == "off" then return 0
		return 1

class DataFormatTimeAgo extends DataFormatterType

	name: "timeago"
	width: 135

	format: (data, options, path) =>
		stamp = DataFormatter.getMoment data
		if stamp == null
			if val then return val
			return "&mdash;"

		age  = moment().diff(stamp) / 1000
		if age < 60
			txt = numeral(age).format("#") + " sec"
		else if age < (60 * 60)
			txt = numeral(age/60).format("#") + " min"
		else if age > 86400
			days = Math.floor(age / 86400)
			hrs  = Math.floor((age - (days * 86400)) / (60 * 60))
			if days != 1 then daysTxt = "days" else daysTxt = "day"
			if hrs > 0
				txt = "#{days} #{daysTxt}, #{hrs} hr"
				if hrs != 1 then txt += "s"
			else
				txt = "#{days} #{daysTxt}"
		else
			hrs = Math.floor(age / (60 * 60))
			min = (age - (hrs * 60 * 60)) / 60
			if hrs > 1 then hrsText = "hrs" else hrsText = "hr"
			txt = numeral(hrs).format("#") + " #{hrsText}, " + numeral(min).format("#") + " min";

		return txt

	unformat: (data, path) =>
		m = DataFormatter.getMoment data
		if !m? then return ""
		return m.format "YYYY-MM-DD HH:mm:ss"


try
	globalDataFormatter = new DataFormatter()

	globalDataFormatter.register(new DataFormatText())
	globalDataFormatter.register(new DataFormatInt())
	globalDataFormatter.register(new DataFormatNumber())
	globalDataFormatter.register(new DataFormatFloat())
	globalDataFormatter.register(new DataFormatCurrency())
	globalDataFormatter.register(new DataFormatDate())
	globalDataFormatter.register(new DataFormatDateTime())
	globalDataFormatter.register(new DataFormatDateAge())
	globalDataFormatter.register(new DataFormatEnum())
	globalDataFormatter.register(new DataFormatDistance())
	globalDataFormatter.register(new DataFormatBoolean())
	globalDataFormatter.register(new DataFormatPercent())
	globalDataFormatter.register(new DataFormatTimeAgo())

catch e
	console.log "Exception while registering global Data Formatter:", e

