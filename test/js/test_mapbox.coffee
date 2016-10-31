$ ->

    addHolder("renderTest1");

    $("#renderTest1").css
        width           : 800
        height          : 600
        border          : "1px solid blue"
        backgroundColor : "#ffffff"

    doAppendView "Mapbox", "#renderTest1"
    .then (mapView)=>
        console.log 'VIEW=', mapView

        mapView.resetView()
        mapView.setView 35.446867, -80.890871, 17
        mapView.setupContextMenu "Map Menu", (e)=>
            console.log "MAP MENU"
