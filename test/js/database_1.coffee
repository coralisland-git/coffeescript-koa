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

            new Promise (resolve, reject) ->

                io.get "/people/1"
                .then (doc)->
                    if !doc?
                        resolve "Valid"
                    else
                        reject "Invalid get response"

        addTest "Set DataEngineIO", ()->

            new Promise (resolve, reject) ->

                io.get "/people/2", true
                .then (doc)->
                    doc.name = 'Brian'
                    io.set "/people/2", doc
                    if doc? and doc.name? and doc.name == "Brian"
                        resolve(true)
                    else
                        console.log "DOC=", doc
                        reject "Invalid doc name value"


        addTest "Get Again DataEngineIO", ()->

            new Promise (resolve, reject) ->

                io.get "/people/2"
                .then (doc) ->

                    ##|  should be set from previous test
                    if !doc? or !doc.name? or doc.name != "Brian"
                        reject "Invalid doc 1"

                    ##|  should not be set
                    if doc? and doc.address?
                        reject "Invalid: address should not yet be set"

                    doc.address =
                        street: "Montibello dr"
                        number: 293

                    io.set "/people/2", doc

                .then (docSave) ->

                    console.log "Doc after set:", docSave
                    io.get "/people/2"

                .then (doc2) ->

                    if !doc2? or !doc2.address? or doc2.address.number != 293
                        console.log "Invalid doc=", doc2
                        reject "Invalid doc2"

                    resolve(true)

        addTest "Get Sub Path", ()->

            new Promise (resolve, reject) ->

                io.get "/people/2/address"
                .then (doc)->
                    if !doc? or !doc.number? or doc.number != 293
                        console.log "Invalid doc=", doc
                        reject "Invalid sub path get"

                    ##|
                    ##|  Set the number from 293 to 111 in the sub path
                    # doc.number = 111
                    doc3 =
                        happy: 12345
                        number: 111

                    io.set "/people/2/address", doc3

                .then ()->

                    ##|
                    ##|  Get the document entirely
                    io.get "/people/2"

                .then (doc4)->

                    if !doc4? or !doc4.address? or !doc4.address.number?
                        reject "Missing doc4"

                    if !doc4.address.happy or doc4.address.happy != 12345
                        reject "Invalid doc4, missing address.happy"

                    if doc4.address.number != 111
                        reject "Invalid doc4, missing number"

                    resolve(true)

        addTest "Get Data from Map", () ->

            new Promise (resolve, reject) ->

                DataMap.addData "people", 2,
                    name: "Test2"
                    age: 100

                .then (doc)->

                    DataMap.getDataField "people", 2, "name"

                .then (currentValue) ->

                    if currentValue == "Test2"
                        resolve true
                    else
                        console.log "Invalid value is ", currentValue
                        reject "Invalid return value"

        go()


    #