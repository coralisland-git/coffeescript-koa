## -------------------------------------------------------------------------------------------------------------
## class to parse the address inside address normalizer scope
##
##
class AddressParser

	# @property [String] address to be parsed default null
	address: null

	# @property [String] seperator parts are seperated using this character default to ,
	seperator: ', '

	# @property [Object] response the parsed address to be stored here
	response: {}

	# @property [Object] states the list of states to be considered in normalization
	states:
		'Alabama': 'AL'
		'Alaska': 'AK'
		'American Samoa': 'AS'
		'Arizona': 'AZ'
		'Arkansas': 'AR'
		'California': 'CA'
		'Colorado': 'CO'
		'Connecticut': 'CT'
		'Delaware': 'DE'
		'District Of Columbia': 'DC'
		'Federated States Of Micronesia': 'FM'
		'Florida': 'FL'
		'Georgia': 'GA'
		'Guam': 'GU'
		'Hawaii': 'HI'
		'Idaho': 'ID'
		'Illinois': 'IL'
		'Indiana': 'IN'
		'Iowa': 'IA'
		'Kansas': 'KS'
		'Kentucky': 'KY'
		'Louisiana': 'LA'
		'Maine': 'ME'
		'Marshall Islands': 'MH'
		'Maryland': 'MD'
		'Massachusetts': 'MA'
		'Michigan': 'MI'
		'Minnesota': 'MN'
		'Mississippi': 'MS'
		'Missouri': 'MO'
		'Montana': 'MT'
		'Nebraska': 'NE'
		'Nevada': 'NV'
		'New Hampshire': 'NH'
		'New Jersey': 'NJ'
		'New Mexico': 'NM'
		'New York': 'NY'
		'North Carolina': 'NC'
		'North Dakota': 'ND'
		'Northern Mariana Islands': 'MP'
		'Ohio': 'OH'
		'Oklahoma': 'OK'
		'Oregon': 'OR'
		'Palau': 'PW'
		'Pennsylvania': 'PA'
		'Puerto Rico': 'PR'
		'Rhode Island': 'RI'
		'South Carolina': 'SC'
		'South Dakota': 'SD'
		'Tennessee': 'TN'
		'Texas': 'TX'
		'Utah': 'UT'
		'Vermont': 'VT'
		'Virgin Islands': 'VI'
		'Virginia': 'VA'
		'Washington': 'WA'
		'West Virginia': 'WV'
		'Wisconsin': 'WI'
		'Wyoming': 'WY'

	## -------------------------------------------------------------------------------------------------------------
	## constructor creates new instance of parser
	##
	## @param [String] address the string to be parsed as address
	##
	constructor: (address) ->
		if !address or !AddressParser.check(address)
			throw 'invalid address supplied'
		@address = address;
		@response =
			warnings: []

	## -------------------------------------------------------------------------------------------------------------
	## return the parts of the address
	## give the parts of the address that can be normalized
	##
	## @return [Object] response the parsed object
	##
	parse: () ->
		@parts = @address.split @seperator

		#| process street_number and street name
		@processStreet($.trim @parts[0])

		@response.city = if $.trim(@parts[1]).length then $.trim(@parts[1]) else undefined
		@response.zipcode = if $.trim(@parts[3]).length then $.trim(@parts[3]) else undefined
		@response.state = @getStateShortName(if $.trim(@parts[2]).length then $.trim(@parts[2]) else undefined)

		##| verify city against zipcode
		@verifyCity()

		##| get zipcode if not found and city/state is given
		@getZipCode()

		if !@response.warnings.length
			delete @response.warnings
		@response


	## -------------------------------------------------------------------------------------------------------------
	## return the street_number, street_prefix, street_suffix
	##
	##
	processStreet: (streetString) ->
		@matches = /^(\d+\s)?(.+)$/.exec streetString
		@response.street_number = @matches[1]
		@streetParts = @matches[2].split " "
		@response.street_prefix = @streetParts[0]
		if @streetParts.length >= 3
			@response.street_direction = if @streetParts[1].length then @streetParts[1] else undefined
			@suffixString = @streetParts[2]
		else if @streetParts.length is 2
			@suffixString = @streetParts[1]
		else
			@suffixString = null

		if @suffixString
			@suffixParser = new StreetSuffixParser()
			@suffix = @suffixParser.getSuffix @suffixString
		@response.street_suffix = @suffix

	## -------------------------------------------------------------------------------------------------------------
	## return 2 character state name from the full name
	##
	## @param [String] state full name of the state
	## @return [String] state 2 character state name
	##
	getStateShortName: (state) ->
		if state and state.length > 2
			if @states[state]
				@states[state]
			else
				@response.warnings.push "State Abbreviation not found"
				state
		else
			state


	## -------------------------------------------------------------------------------------------------------------
	## verify city against provided zipcode and if invalid inserts warning
	##
	##
	verifyCity: ->
		if @response.zipcode and @response.city
			_city = DataMap.getDataField('zipcode', @response.zipcode, 'city');
			if _city != @response.city
				@response.warnings.push("Invalid City #{@response.city} != #{_city}")

	## -------------------------------------------------------------------------------------------------------------
	## check if zipcode is not available it gets from city/state
	##
	##
	getZipCode: ->
		if !@response.zipcode and (@response.city or @response.state)
			_zipObj = DataMap.getValuesFromTable 'zipcode', (obj) =>
				return obj.city is @response.city or obj.state is @response.state
			.pop()
			if _zipObj.hasOwnProperty 'key'
				if !@response.state
					@response.state = DataMap.getDataMap().data['zipcode'][_zipObj.key].state;
				@response.zipcode = _zipObj.key

	## -------------------------------------------------------------------------------------------------------------
	## return true if the given address is valid
	##
	##
	@check: (address) ->
		/^(\d+\s)?[\w\s'.,]+(\d{5}|\d{5}-\d{4})?$/.test address

try
	## create global instance of address parser
	GlobalAddressParser = new AddressParser '2467 Bearded Iris Lane, High Point, North Carolina, 27265';
catch e
	console.log "Exception while registering global Address Parser:", e
