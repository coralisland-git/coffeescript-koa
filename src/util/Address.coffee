try
  GlobalAddressNormalizer = new AddressNormalizer({city:'sample'});
  GlobalStreetSuffixParser = new StreetSuffixParser();
catch e
  console.log "Exception while registering global Address Formatter:", e