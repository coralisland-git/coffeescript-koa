## -------------------------------------------------------------------------------------------------------------
## class to normalize the address which is us format
##
## @example
##      s = new AddressNormalizer
##                  street_number: 1415
##                  street_prefix: 'Old'
##                  street_direction: 'Salisbury'
##                  street_suffix: 'Road'
##    return s.getAddressPart();
##
class AddressNormalizer

    # @property [mixed] lat latitude in the address default null
    lat: null

    # @property [mixed] lon longitude in the address default null
    lon: null

    # @property [mixed] tile_x default null
    tile_x: null

    # @property [mixed] tile_y default null
    tile_y: null

    # @property [mixed] house_number the house number component of address default null
    house_number     : null

    # @property [mixed] street_number the street number component of address default null
    street_number    : null

    # @property [mixed] street_prefix the street prefix component of address default null
    street_prefix    : null

    # @property [mixed] street_direction the street direction component of address default null
    street_direction : null

    # @property [mixed] street_suffix the street suffix component of address default null
    street_suffix    : null

    # @property [mixed] unit_number the unit number component of address default null
    unit_number: null

    # @property [mixed] city the city component of address default null
    city    : null

    # @property [mixed] state the state component of address default null
    state   : null

    # @property [mixed] zipcode the zipcode component of address default null
    zipcode : null

    # @property [mixed] zipfour the zip four digit component of address default null
    zipfour : null

    # @property [mixed] seperator the seperator for address default ,
    seperator: ', '

    ## -------------------------------------------------------------------------------------------------------------
	## constructor new tab instance
	##
	## @param [Object] options the predefined and known components of the address
	##
    constructor: (options) ->
        ##|  options can be used to pass in known information
        if options.city? then @city = @fixTitleCase options.city
        if options.lat? then @lat = options.lat
        if options.lon? then @lon = options.lon
        if options.tile_x? then @tile_x = options.tile_x
        if options.tile_y? then @tile_y = options.tile_y
        if options.street_number? then @street_number = options.street_number
        if options.street_prefix? then @street_prefix = options.street_prefix
        if options.street_direction? then @street_direction = options.street_direction
        if options.street_suffix? then @street_suffix = options.street_suffix
        if options.unit_number? then @unit_number = options.unit_number
        if options.state? then @state = options.state
        if options.zipcode? then @zipcode = options.zipcode
        if options.zipfour? then @zipfour = options.zipfour

    ## -------------------------------------------------------------------------------------------------------------
	## return the single line of text that is the address
	##
	## @return [String] normalized to be comparable address
	##
    getDisplayAddress: () =>
        "#{@getAddressPart()}, #{if @unit_number then @unit_number+', ' else ''} #{if @city then @city+', ' else '' } #{if @state then @state+', ' else ''} #{if @zipcode then @extractZip() else ''}"

    ## -------------------------------------------------------------------------------------------------------------
	## convert text from unknown case to title case, as in
	##
    ## @example PHOENIX becomes Phoenix, NEW york becomes New York
	## @param [String] strTitleText text to be converted
    ## @return [String] converted text
	##
    fixTitleCase: (strTitleText) =>
        strTitleText.replace /\w\S*/g, (txt) ->
            txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()

    ## -------------------------------------------------------------------------------------------------------------
	## process the address part and create address part string
	##
    ## @example street_prefix, street_direction, street_suffix Unit
	## @return [String] the full part of the address
	##
    getAddressPart: () =>
        suffixParser = new StreetSuffixParser();
        "#{if @street_number then @street_number else ""} #{if @street_prefix then @street_prefix else ""} #{if @street_direction then @street_direction else ""} #{if @street_suffix then suffixParser.getSuffix(@street_suffix) else ''}"

    ## -------------------------------------------------------------------------------------------------------------
	## extract 5 digit zipcode if zipcode is 9 digits
	##
	## @return [String] zip the extracted zip if 9 digit than first 5 digit will be returned
	##
    extractZip: () =>
        if(/^\d{5}-\d{4}$/.test @zipcode)
            zip = @zipcode.split('-')[0]
        else
            zip = @zipcode



try
    ## initialize the addressNormalizer in global scope
    GlobalAddressNormalizer  = new AddressNormalizer({city:'sample'});
catch e
    console.log "Exception while registering global Address Formatter:", e
