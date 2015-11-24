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
  go()