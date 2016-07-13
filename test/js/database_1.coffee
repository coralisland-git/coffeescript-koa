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

    if true
        console.log "Adding tests"

        io = new DataMapEngine "test"

        addTest "Init DataEngineIO", ()->

            doc = io.get "/people/1"
            if !doc?
                return "Yes"
            else
                return "Invalid doc response"

        addTest "Set DataEngineIO", ()->

            doc = io.get "/people/2", true
            doc.name = 'Brian'
            io.set "/people/2", doc
            if doc? and doc.name? and doc.name == "Brian"
                return true
            else
                console.log "DOC=", doc
                return "Invalid doc name value"


        addTest "Get Again DataEngineIO", ()->

            doc = io.get "/people/2"

            ##|  should be set from previous test
            if !doc? or !doc.name? or doc.name != "Brian"
                return "Invalid doc 1"

            ##|  should not be set
            if doc? and doc.address?
                return "Invalid: address should not yet be set"

            doc.address =
                street: "Montibello dr"
                number: 293

            docSave = io.set "/people/2", doc
            console.log "Doc after set:", docSave

            doc2 = io.get "/people/2"
            if !doc2? or !doc2.address? or doc2.address.number != 293
                console.log "Invalid doc=", doc2
                return "Invalid doc2"

            return true

        addTest "Get Sub Path", ()->

            doc = io.get "/people/2/address"
            if !doc? or !doc.number? or doc.number != 293
                console.log "Invalid doc=", doc
                return "Invalid sub path get"

            ##|
            ##|  Set the number from 293 to 111 in the sub path
            # doc.number = 111
            doc3 =
                happy: 12345
                number: 111

            io.set "/people/2/address", doc3

            doc4 = io.get "/people/2"
            if !doc4? or !doc4.address? or !doc4.address.number?
                return "Missing doc4"

            if !doc4.address.happy or doc4.address.happy != 12345
                return "Invalid doc4, missing address.happy"

            if doc4.address.number != 111
                return "Invalid doc4, missing number"

            return true

        addTest "Get Data from Map", () ->

            doc = DataMap.addData "people", 2,
                name: "Test2"
                age: 100

            currentValue = DataMap.getDataField "people", 2, "name"

            if currentValue == "Test2"
                return true
            else
                console.log "Invalid value is ", currentValue
                return "Invalid return value"

        go()


    #