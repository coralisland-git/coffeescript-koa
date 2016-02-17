$ ->

  addTest "City Title Case Test", ()->
    GlobalAddressNormalizer.fixTitleCase "new york"

  addTest "City Title Case Test varient", ()->
    GlobalAddressNormalizer.fixTitleCase "los angeles"

  addTest "Street Suffix Parser Test Case", ()->
    GlobalStreetSuffixParser.getSuffix "Drive"

  addTest "Street Suffix Parser Test Case", ()->
    GlobalStreetSuffixParser.getSuffix "Lane"

  addTest "Street Suffix Parser Test Case", ()->
    GlobalStreetSuffixParser.getSuffix "Ridge"

  addTest "Zipcode extractor Test Case", ()->
    normalizer = new AddressNormalizer
      zipcode: '12345-6789'
    normalizer.extractZip()

  addTest "Get Address Part Test Case", ()->
    s = new AddressNormalizer
              street_number:1415
              street_prefix: 'Old'
              street_direction: 'Salisbury'
              street_suffix: 'Road'
    s.getAddressPart()

  addTest "Get Address Part Test Case", ()->
    s = new AddressNormalizer
      street_number:326
      street_prefix: 'Robyn\'s'
      street_direction: 'Glen'
      street_suffix: 'Circle'
    s.getAddressPart()

  addTest "Get display Address Test Case", ()->
    s = new AddressNormalizer
      street_number:326
      street_prefix: 'Robyn\'s'
      street_direction: 'Glen'
      street_suffix: 'Circle'
      city: 'Greensboro',
      state: 'North Carolina',
      zipcode: '27409'
    s.getDisplayAddress()

  addTest "Get display Address Test Case", ()->
    s = new AddressNormalizer
      street_number:1318
      street_prefix: 'Forsyth'
      city: 'Kernersville',
      state: 'North Carolina',
      zipcode: '27284'
    s.getDisplayAddress()

  addTest "Get display Address Test Case", ()->
    s = new AddressNormalizer
      street_number:2467
      street_prefix: 'Bearded',
      street_direction: 'Iris',
      street_suffix: 'Lane',
      city: 'High Point',
      state: 'North Carolina',
      zipcode: '27265'
    s.getDisplayAddress()


  addTest "Loading Zipcodes", () ->
    new Promise (resolve, reject) ->
      ds  = new DataSet "zipcode"
      ds.setAjaxSource "/js/test_data/zipcodes.json", "data", "code"
      ds.doLoadData()
      .then (dsObject)->
        resolve(true)
      .catch (e) ->
        console.log "Error loading zipcode data: ", e
        resolve(false)

  addTest "Parse the address string and makes address parts", ()->
    a = new AddressParser '2467 Bearded Iris Lane, Agawam, North Carolina, 01001'
    object = a.parse()
    JSON.stringify object, null, 4

  addTest "Parse the address string and makes address parts", ()->
    a = new AddressParser '627 Riverside Drive, Amherst, Florida, 01002'
    object = a.parse()
    JSON.stringify object, null, 4

  addTest "Parse the address string and makes address parts", ()->
    a = new AddressParser "360 5th Avenue, Chicopee, Ohio, 01021"
    object = a.parse()
    JSON.stringify object, null, 4

  addTest "Parse the address string without city and zipcode", ()->
    a = new AddressParser "1415 Old Salisbury Road"
    object = a.parse()
    JSON.stringify object, null, 4

  addTest "Parse the address string without street number", ()->
    a = new AddressParser "Robyn's Glen Circle, Cummington, North Carolina, 01026"
    object = a.parse()
    JSON.stringify object, null, 4

  addTest "Parse the address string with invalid state name", ()->
    a = new AddressParser '627 Riverside Drive, Hollywood, Floridaa, 01008'
    object = a.parse()
    JSON.stringify object, null, 4

  addTest "Parse the address string with different zip and city", ()->
    a = new AddressParser "360 5th Avenue, Easthampton, Ohio, 01021"
    object = a.parse()
    JSON.stringify object, null, 4

  addTest "Parse the address string without zip code and with city", ()->
    a = new AddressParser "360 5th Avenue, Easthampton"
    object = a.parse()
    JSON.stringify object, null, 4

  addTest "Parse the address string without zip code and with state/city", ()->
    a = new AddressParser "360 5th Avenue, Mashpee, Massachusetts"
    object = a.parse()
    JSON.stringify object, null, 4
  go()