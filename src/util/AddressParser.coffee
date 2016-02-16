class AddressParser

  address: null

  seperator: ', '

  response: {}

  constructor: (address) ->
##|  pass address string to be parsed| seperator which is used to differentiate parts of the address
    if !address or !AddressParser.check(address)
      throw 'invalid address supplied'
    @address = address;
    @response = {}


##|
##|  Return the parts of the address
##|  give the parts of the address that can be normalized
  parse: () ->
    @parts = @address.split @seperator

    #| process street_number and street name
    @processStreet($.trim @parts[0])

    @response.city = $.trim @parts[1]
    @response.state = $.trim @parts[2]
    @response.zipcode = $.trim @parts[3]
    @response

##|
##| Return the street_number, street_prefix, street_suffix
  processStreet: (streetString) ->
    @matches = /^(\d+)\s(.+)$/.exec streetString
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
##|
##| Return true if the given address is valid
  @check: (address) ->
    /^\d+\s[\w\s']+,[\w\s.]+,[\s\w]+,\s?(\d{5}|\d{5}-\d{4})$/.test address

try
  GlobalAddressParser  = new AddressParser '2467 Bearded Iris Lane, High Point, North Carolina, 27265';
catch e
  console.log "Exception while registering global Address Parser:", e