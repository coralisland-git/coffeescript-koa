DataSetConfig = require 'edgecommondatasetconfig'
dataFormatter   = new DataSetConfig.DataFormatter()

$ ->
	
	addTest "Text test", ()->
		dataFormatter.formatData "text", "Text value"

	addTest "Number as text", () ->
		dataFormatter.formatData "text", 1234

	addTest "Number as int (no decimals output)", () ->
		dataFormatter.formatData "int", 1234

	addTest "Decimal as int (no decimals output)", () ->
		dataFormatter.formatData "int", 1234.123

	addTest "int as number (2 decimals output if needed)", () ->
		dataFormatter.formatData "number", 1234

	addTest "Decimal as number (2 decimals output if needed)", () ->
		dataFormatter.formatData "number", 1234.123

	addTest "int as decimal (2 decimals output always)", () ->
		dataFormatter.formatData "decimal", 1234

	addTest "Decimal as decimal (2 decimals output always)", () ->
		dataFormatter.formatData "decimal", 1234.123

	addTest "int as currency (2 decimals output if needed)", () ->
		dataFormatter.formatData "money", 1234

	addTest "Decimal as currency (2 decimals output always)", () ->
		dataFormatter.formatData "money", 1234.123

	addTest "Percent", () ->
		dataFormatter.formatData "percent", 0.25

	addTest "MySQL Date to Date (no time, simple US output)", () ->
			dataFormatter.formatData "date", "2015-10-31 14:15:32"

	addTest "MySQL Date to DateTime (pretty printed date time)", () ->
		dataFormatter.formatData "datetime", "2015.10.31 14:15:32"

	addTest "MySQL Date to Age (Date with days ago)", () ->
		dataFormatter.formatData "age", "2015-10-31 14:15:32"

	addTest "MySQL Date to Timeago", () ->
		dataFormatter.formatData "timeago", "2015-10-01 14:15:32"
	
	addTest "US Date to Date (no time, simple US output)", () ->
			dataFormatter.formatData "date", "10/02/2015"

	addTest "US Date to DateTime (pretty printed date time)", () ->
		dataFormatter.formatData "datetime", "10/02/2015 14:15:32"

	addTest "US Date to Age (Date with days ago)", () ->
		dataFormatter.formatData "age", "10/31/2015"

	addTest "Enum test, value is one of the array options", () ->
		dataFormatter.formatData "enum", "Blue", ["Red","Green","Blue","Pink"]

	addTest "Enum test, value is not of the array options (should print anyway)", () ->
		dataFormatter.formatData "enum", "Blue", ["Red","Green","Blue","Pink"]

	addTest "Enum test, value is an index (should print Green)", () ->
		dataFormatter.formatData "enum", 1, ["Red","Green","Blue","Pink"]

	addTest "Enum test, value is an index (list is text)", () ->
		dataFormatter.formatData "enum", 1, "Red,Green,Blue,Pink"

	addTest "Distance (should print feet)", ()->
		dataFormatter.formatData "distance", 0.250

	addTest "Distance (should print in miles)", ()->
		dataFormatter.formatData "distance", 500

	addTest "Boolean simple true", ()->
		dataFormatter.formatData "boolean", 1

	addTest "Boolean simple true", ()->
		dataFormatter.formatData "boolean", "Yes"

	addTest "Boolean simple false", ()->
		dataFormatter.formatData "boolean", 0

	addTest "Boolean simple false", ()->
		dataFormatter.formatData "boolean", null

	addTest "Boolean simple false", ()->
		dataFormatter.formatData "boolean", false

	addTest "Boolean simple true", ()->
		dataFormatter.formatData "boolean", true

	addTest "Tags as string", ()->
		dataFormatter.formatData "tags", "Apple,Grape,Watermellon"

	addTest "Tags as array", ()->
		dataFormatter.formatData "tags", ["Apple","Grape","Watermellon"]

	addTest "Create a new data formatting class dynamically", () ->

		dataFormatter.register
			name: "test"
			format: (data, options, path) =>
				return "[<b>" + data + "</b>]"

		dataFormatter.formatData "test", "Testing"

	go()

	# dataFormatter.register(new DataFormatTimeAgo())