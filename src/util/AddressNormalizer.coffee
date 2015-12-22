class AddressNormalizer

    lat: null
    lon: null

    tile_x: null
    tile_y: null

    house_number     : null
    street_number    : null
    street_prefix    : null
    street_direction : null
    street_suffix    : null

    unit_number: null

    city    : null
    state   : null
    zipcode : null
    zipfour : null

    seperator: ', '

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

    ##|
    ##|  Return the single line of text that is the address
    ##|  normalized to be comparable
    getDisplayAddress: () =>
        "#{@getAddressPart()}, #{if @unit_number then @unit_number+', ' else ''} #{if @city then @city+', ' else '' } #{if @state then @state+', ' else ''} #{if @zipcode then @extractZip() else ''}"
    ##|
    ##|  Convert text from unknown case to title case, as in
    ##|  PHOENIX becomes Phoenix
    ##|  NEW york becomes New York
    ##|  MCARTHUR AIRpORT becomes McArthur Airport
    fixTitleCase: (strTitleText) =>
        strTitleText.replace /\w\S*/g, (txt) ->
            txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()

    ##| process the address part and create address part string
    ##| ex. street_prefix, street_direction, street_suffix Unit
    getAddressPart: () =>
        suffixParser = new StreetSuffixParser();
        "#{if @street_number then @street_number else ""} #{if @street_prefix then @street_prefix else ""} #{if @street_direction then @street_direction else ""} #{if @street_suffix then suffixParser.getSuffix(@street_suffix) else ''}"

    ##| extract 5 digit zipcode if zipcode is 9 digits
    extractZip: () =>
        if(/^\d{5}-\d{4}$/.test @zipcode)
            zip = @zipcode.split('-')[0]
        else
            zip = @zipcode


