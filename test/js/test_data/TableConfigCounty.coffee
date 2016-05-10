TableConfigCounty = []

TableConfigCounty.push
    name     : 'Population'
    source   : 'population'
    visible  : true
    hideable : false
    editable : true
    type     : 'int'
    required : false
    width    : 80
    align    : "right"

$ ->
    ##|
    ##| Configure the global map
    root.DataMap.setDataTypes "county", TableConfigCounty

    # DataMap.addData "county", "SUFFOLK",
    #     county: "SUFFOLK"
    #     population: 12345

    # DataMap.addData "county", "HAMPSHIRE",
    #     county: "HAMPSHIRE"
    #     population: 23312

    # DataMap.addData "county", "HAMPDEN",
    #     county: "HAMPDEN"
    #     population: 1111

    # DataMap.addData "county", "BERKSHIRE",
    #     county: "BERKSHIRE"
    #     population: 9999

