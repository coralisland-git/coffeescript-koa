class TestClass1

    constructor: (@name)->
        console.log "Here: TestClass1 Constructor"
        GlobalClassTools.addEventManager(this)

    runTest: ()=>
        setTimeout ()=>
            @emitEvent "sample_event", ["A", "B", "C"]
        , 1000

        @on "sample_event", (a, b, c) =>
            console.log "TestClass1: Sample event: A=#{a} B=#{b} C=#{c}"
            console.log "TestClass1: Checking for @name which should not be defined:", @name
            true

        console.log "Here: TestClass1 Event timer setup"
        true

$ ->

    addTest "Dynamic Class Test", ()->

        new Promise (resolve, reject)->

            t = new TestClass1("TestName")
            t.on "sample_event", (a, b, c) =>

                console.log "Document: Sample event: A=#{a} B=#{b} C=#{c}"
                console.log "Document: Checking for @name which should not be defined, we are in the context of the test case"
                console.log "Document: name (should not be defined)", @name
                resolve(!@name?)
                true

            t.runTest()

        true

    go()