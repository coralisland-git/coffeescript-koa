$ ->
	
	addTest "Text test", ()->
		globalDataFormatter.formatData "text", "Text value"

	addTest "Number as text", () ->
		globalDataFormatter.formatData "text", 1234

	addTest "Number as int (no decimals output)", () ->
		globalDataFormatter.formatData "int", 1234

	addTest "Decimal as int (no decimals output)", () ->
		globalDataFormatter.formatData "int", 1234.123

	addTest "int as number (2 decimals output if needed)", () ->
		globalDataFormatter.formatData "number", 1234

	addTest "Decimal as number (2 decimals output if needed)", () ->
		globalDataFormatter.formatData "number", 1234.123

	addTest "int as decimal (2 decimals output always)", () ->
		globalDataFormatter.formatData "decimal", 1234

	addTest "Decimal as decimal (2 decimals output always)", () ->
		globalDataFormatter.formatData "decimal", 1234.123

	addTest "int as currency (2 decimals output if needed)", () ->
		globalDataFormatter.formatData "money", 1234

	addTest "Decimal as currency (2 decimals output always)", () ->
		globalDataFormatter.formatData "money", 1234.123

	addTest "Percent", () ->
		globalDataFormatter.formatData "percent", 0.25

	addTest "MySQL Date to Date (no time, simple US output)", () ->
			globalDataFormatter.formatData "date", "2015-10-31 14:15:32"

	addTest "MySQL Date to DateTime (pretty printed date time)", () ->
		globalDataFormatter.formatData "datetime", "2015.10.31 14:15:32"

	addTest "MySQL Date to Age (Date with days ago)", () ->
		globalDataFormatter.formatData "age", "2015-10-31 14:15:32"

	addTest "MySQL Date to Timeago", () ->
		globalDataFormatter.formatData "timeago", "2015-10-01 14:15:32"
	
	addTest "US Date to Date (no time, simple US output)", () ->
			globalDataFormatter.formatData "date", "10/02/2015"

	addTest "US Date to DateTime (pretty printed date time)", () ->
		globalDataFormatter.formatData "datetime", "10/02/2015 14:15:32"

	addTest "US Date to Age (Date with days ago)", () ->
		globalDataFormatter.formatData "age", "10/31/2015"

	addTest "Enum test, value is one of the array options", () ->
		globalDataFormatter.formatData "enum", "Blue", ["Red","Green","Blue","Pink"]

	addTest "Enum test, value is not of the array options (should print anyway)", () ->
		globalDataFormatter.formatData "enum", "Blue", ["Red","Green","Blue","Pink"]

	addTest "Enum test, value is an index (should print Green)", () ->
		globalDataFormatter.formatData "enum", 1, ["Red","Green","Blue","Pink"]

	addTest "Enum test, value is an index (list is text)", () ->
		globalDataFormatter.formatData "enum", 1, "Red,Green,Blue,Pink"

	addTest "Distance (should print feet)", ()->
		globalDataFormatter.formatData "distance", 0.250

	addTest "Distance (should print in miles)", ()->
		globalDataFormatter.formatData "distance", 500

	addTest "Boolean simple true", ()->
		globalDataFormatter.formatData "boolean", 1

	addTest "Boolean simple true", ()->
		globalDataFormatter.formatData "boolean", "Yes"

	addTest "Boolean simple false", ()->
		globalDataFormatter.formatData "boolean", 0

	addTest "Boolean simple false", ()->
		globalDataFormatter.formatData "boolean", null

	addTest "Boolean simple false", ()->
		globalDataFormatter.formatData "boolean", false

	addTest "Boolean simple true", ()->
		globalDataFormatter.formatData "boolean", true

	addTest "Tags as string", ()->
		globalDataFormatter.formatData "tags", "Apple,Grape,Watermellon"

	addTest "Tags as array", ()->
		globalDataFormatter.formatData "tags", ["Apple","Grape","Watermellon"]

	addTest "Create a new data formatting class dynamically", () ->

		globalDataFormatter.register
			name: "test"
			format: (data, options, path) =>
				return "[<b>" + data + "</b>]"

		globalDataFormatter.formatData "test", "Testing"

	go()

	# globalDataFormatter.register(new DataFormatTimeAgo())