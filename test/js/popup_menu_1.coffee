$ ->

    addTest "Simple Popup Menu", ()->

        button = $ "<div />",
            class: "btn btn-primary"
            html: "Popup Test 1"
        .bind 'click', (e) ->

            menu = new PopupMenu "Test Title", e

            menu.addItem "Item 1", (data) ->
                console.log "Clicked item 1: ", data
            , 100

            menu.addItem "Item 2", (data) ->
                console.log "Clicked item 2: ", data
            , 100

    addTest "Custom Size and Location", ()->

        button = $ "<div />",
            class: "btn btn-primary"
            html: "Popup Test 2"
        .bind 'click', (e) ->

            e.preventDefault()
            e.stopPropagation()

            menu = new PopupMenu "Test Title", 30, 30
            menu.resize(500)

            menu.addItem "Item 1", (data) ->
                console.log "Clicked item 1: ", data
            , 100

            menu.addItem "Item 2", (data) ->
                console.log "Clicked item 2: ", data
            , 100

    addTest "Popup Calendar", ()->

        button = $ "<div />",
            class: "btn btn-primary"
            html: "Calendar Test 1"
        .bind 'click', (e) ->

            menu = new PopupMenuCalendar "Calendar", e
            menu.onCheck = (e, data) ->
                console.log "E=", e
                console.log "DATA=", data

    addTest "Popup menu with badge and icon", ()->

        button = $ "<div />",
            class: "btn btn-primary"
            html: "Calendar Test 1"
        .bind 'click', (e) ->
            e.preventDefault()
            e.stopPropagation()

            menu = new PopupMenu "Test Title", 30, 30
            
            (menu.addItem "Item 1", (data) ->
                console.log "Clicked item 1: ", data
            , 100).setBadge(5).setClass('primary').setIcon("fa fa-edit")

            menu.addItem "Item 2", (data) ->
                console.log "Clicked item 2: ", data
            , 100
            menu.resize(500)
    go()