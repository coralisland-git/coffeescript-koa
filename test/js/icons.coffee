doCopyIcon = (o)->
    console.log "COPY:", $(o).text()
    copyToClipboard $(o).text()

$ ->

    addHolder()
    .setView "TestIcons", (view)->
        console.log "Icon View done"

    