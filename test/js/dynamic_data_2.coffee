$ ->

    $("body").append '''
        <style type="text/css">
        .data {
            width  : 300px;
            border : 1px solid #bbbbdd;
            color  : #309030
        }
        </style>
    '''

    demoMode = 0

    zipcodeData1 =
        code   : "03105"
        city   : "Manchester"
        state  : "NH"
        county : "HILLSBOROUGH"
        lat    : "42.952124"
        lon    : "-71.653939"

    addTest "Confirm DataMap Loaded", ()->

        dm = DataMap.getDataMap()
        if !dm? then return false

        zipcodes = dm.types["zipcode"]
        if !zipcodes? then return false
        if !zipcodes.col["code"]? then return false

        true

    addTest "Set Data", () ->

        DataMap.addData "zipcode", "03105", zipcodeData1

    addTest "Render Field", () =>

        html  = "<br>6 fields, last 2 are editable:<br><div>";
        html += DataMap.renderField("div", "zipcode", "code", "03105")
        html += DataMap.renderField "div", "zipcode", "city", "03105"
        html += DataMap.renderField "div", "zipcode", "state", "03105"
        html += DataMap.renderField "div", "zipcode", "county", "03105"
        html += DataMap.renderField "div", "zipcode", "lat", "03105"
        html += DataMap.renderField "div", "zipcode", "lon", "03105"
        html += "</div>";

        $("#testCase").append($ html)
        true

    addTest "Render Property", () ->

        DataMap.addData "property", 1234,
            id: 1234
            address: "1234 Fake Street"
            pool: "Yes"

        console.log DataMap.getDataMap().data["property"]

        html  = "<br>Three property table fields, id, address, pool <br><table><tr>";
        html += DataMap.renderField "td", "property", "id", 1234
        html += DataMap.renderField "td", "property", "address", 1234
        html += DataMap.renderField "td", "property", "pool", 1234
        html += "</tr></table>";

        $("#testCase").append($ html)
        true

    addTestButton "Change value", "Change NH to CA", () =>

        # don't do this because it won't register the change
        # zipcodeData1.state = "CA"

        DataMap.addData "zipcode", "03105",
            state: "CA"

        true

    go()


#