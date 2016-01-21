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

        html  = "<div>";
        html += DataMap.renderField("div", "zipcode", "code", "03105")
        html += DataMap.renderField "div", "zipcode", "city", "03105"
        html += DataMap.renderField "div", "zipcode", "state", "03105"
        html += DataMap.renderField "div", "zipcode", "county", "03105"
        html += DataMap.renderField "div", "zipcode", "lat", "03105"
        html += DataMap.renderField "div", "zipcode", "lon", "03105"
        html += "</div>";

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