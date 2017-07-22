$ ->

    addTestButton "Basic Blockly", "Open", ()->

        addHolder()
        .setView "Blockly", (viewBlockly)->
            console.log "VB=", viewBlockly

        true

    go()