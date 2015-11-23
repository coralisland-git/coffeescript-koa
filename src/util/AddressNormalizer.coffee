class AddressNormalizer

    lat: null
    lon: null

    tile_x: null
    tile_y: null

    street_number: null
    street_prefix: null
    street_direction: null
    street_suffix: null

    unit_number: null

    city: null
    state: null
    zipcode: null
    zipfour: null

    constructor: (options) ->

        ##|  options can be used to pass in known information
        if options.city? then @city = @fixTitleCase options.city

    ##|
    ##|  Return the single line of text that is the address
    ##|  normalized to be comparable
    getDisplayAddress: () =>

    ##|
    ##|  Convert text from unknown case to title case, as in
    ##|  PHOENIX becomes Phoenix
    ##|  NEW york becomes New York
    ##|  MCARTHUR AIRpORT becomes McArthur Airport
    fixTitleCase: (strTitleText) =>
        strTitleText.replace /\w\S*/g, (txt) ->
            txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()



