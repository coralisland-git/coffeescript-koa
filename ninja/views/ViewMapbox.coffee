class ViewMapbox extends View


    geoJsonInit: ()=>

        geoJson =
          type: 'FeatureCollection',
          features: [
          ]

        return geoJson

    geoJsonAddLocation: (geoJson, location, options)=>

        point =
            type: 'Feature'
            geometry: location
            properties:
                title: ""
                description: ""

        if options?
            $.extend point.properties, options

        geoJson.features.push point
        return point

    geoJsonAddPoint: (geoJson, lat, lon, options)=>

        point =
            type: 'Feature'
            geometry:
                type: 'Point'
                coordinates: [lon, lat]
            properties:
                title: ""
                description: ""

        if options?
            $.extend point.properties, options

        geoJson.features.push point
        return point

    ##|
    ##|   Set the viewport given a location
    setView: (lat, lon, zoomLevel = 16) =>

        if @map?
            ##|
            ##|  Set the location on the map
            @map.setView [lat, lon], zoomLevel

        true

    onResize: ()=>

        if !@elHolder?
            return

        pos    = @elHolder.position()
        width  = @elHolder.outerWidth()
        height = @elHolder.outerHeight()

        $("#map").css
            left   : pos.left
            top    : pos.top
            width  : width
            height : height

        true

    onShowScreen: () =>

        @allPoints = []
        @allLayers = []
        @contextMenuEventSet = 0

        @styleParcel =
            "color" : "rgba(135, 210, 223, 0.5)"
            "border" : "1px solid rgba(46, 161, 243, 0.20)"

        @styleParcelHover =
            "color" : "rgba(237, 192, 80, 1.0)"
            "border" : "1px solid rgba(217, 172, 60, 1.0)"

        ##|
        ##|  Setup MapBox primary object

        L.mapbox.accessToken = 'pk.eyJ1IjoiYnJpYW5wb2xsYWNrIiwiYSI6IkdtQ2lqSmcifQ.jazOduUIH0pj8dRBFtZAGg'
        key                  = 'brianpollack.hol7n21h';

        @map = L.mapbox.map 'map', key,
            zoomControl:        true
            featureLayer:       true
            infoControl:        false
            attributionControl: false
            zoom:               17
            maxZoom:            19
            maxNativeZoom:      19
            minNativeZoom:      5
            minZoom:            5

        @map.on "load", (e) =>
            console.log "Bounds=", @map.getBounds();

        @map.on "zoomed", (e) =>
            console.log "Bounds=", @map.getBounds();

        @map.on "resize", (e) =>
            console.log "MAP RESIZE:", e
            # console.log "Bounds=", @map.getBounds();

        @linkOtherMaps = $("#externalMapsLink")
        @linkOtherMaps.on "click", (e) =>
            console.log "Point=", @mapPointLat, @mapPointLon
            console.log "L=", @mapLabel

            e.stopPropagation();
            coords = GlobalValueManager.GetCoordsFromEvent e
            popup  = new PopupMenu("External Maps", coords.x - 150, coords.y - 10)
            popup.addItem "Google Maps", @onExternalGoogle
            popup.addItem "Bing Maps", @onExternalBing

    onExternalGoogle: () =>
        address = escape "#{window.currentProperty.property.address.display}"
        link = "http://maps.google.com/?q=#{address}&z=19&t=h&f=l"
        window.open(link, "mapWindow", "height=800,width=1200,menubar=no,toolbar=no,location=no,status=no,resizable=yes")

    onExternalBing: () =>
        link = "http://bing.com/maps/default.aspx?cp=#{@mapPointLat}~#{@mapPointLon}&lvl=18&style=b"
        window.open(link, "mapWindow", "height=800,width=1200,menubar=no,toolbar=no,location=no,status=no,resizable=yes")

    resetView: =>

        if @allLayers? and @allLayers.length
            @map.removeLayer o for o in @allLayers

        if @allPoints? and @allPoints.length?
            @map.removeLayer o for o in @allPoints

        @allPoints = []
        @allLayers = []

        @mapPointLat = 0
        @mapPointLon = 0

        @map.invalidateSize()
        @setupMapLinks()

    addGeoShape: (geo, id, delegate, labelText) =>

        if typeof geo == "string"
            try
                geo = JSON.parse(geo)
            catch
                console.log "addGeoShape: Error parsing shape: ", geo
                return false

        if typeof geo == "undefined" or typeof geo != "object"
            api.RecordError "addGeoShape, expecting geo to be object, instead: " + JSON.stringify(geo)
            return false

        geoJson = geo
        geoJson.properties =
            pid = id

        layer = L.geoJson geoJson,
            the_id : id
            delegate: delegate

            pointToLayer: (feature, latlng) =>
                houseMarker = L.marker latlng,
                    icon: @purpleHomeIcon
                return houseMarker

            style: (feature) =>
                return @styleParcelƒon

        layer.options.who = layer

        layer.bindLabel labelText

        layer.on 'mouseover', (e) =>
            e.target.options.delegate.onMouseOverParcel e.target.options
            true

        layer.on 'mouseout', (e) =>
            e.target.options.delegate.onMouseOutParcel e.target.options
            true

        layer.on 'click', (e) =>
            e.target.options.delegate.onMouseClickParcel e.target.options
            true

        layer.addTo(@map)
        # @allLayers.push layer
        @allPoints.push layer
        return layer

    fitAll: () =>
        @map.invalidateSize();
        if @allPoints.length > 0
            group = new L.featureGroup(@allPoints);
            @map.fitBounds(group.getBounds())

        @setupMapLinks()

    setupMapLinks: () =>

        ##|
        ##|  Map links
        if @mapPointLat
            @linkOtherMaps.show()
        else
            @linkOtherMaps.hide()

    clearLineToHome: () =>

        if @markerLine?
            @markerLine.setLatLngs([])

        true

    addLineToHome: (lat, lon, title)=>

        if !@homeLocation
            console.log "Warning:  can't addLineToHome without homeLocation"
            return

        if !@markerLine?
            options =
                color: '#EBDAB8'
            @markerLine = L.polyline([], options).addTo(@map);

        points = [ new L.latLng(@homeLocation[1], @homeLocation[0]), new L.latLng(lat, lon) ]
        @markerLine.setLatLngs points
        true

    addGeoJsonLayer: (geoJson)=>

        myLayer = L.mapbox.featureLayer().addTo(@map);
        myLayer.setGeoJSON geoJson
        @allPoints.push myLayer
        return myLayer

    addGreenHome: (geoJson) =>

        lat = geoJson.features[0].geometry.coordinates[1]
        lon = geoJson.features[0].geometry.coordinates[0]

        @homeLat      = lat
        @homeLon      = lon
        @mapPointLat  = lat
        @mapPointLon  = lon
        @homeLocation = [lon, lat]

        @addGeoJsonLayer geoJson
        @map.setView [lat, lon], 18

        @linkOtherMaps.show()

    addHome: (lat, lon, listing_status, delegate, dataKey, labelText) =>

        if lat == @homeLat and lon == @homeLon then return

        myIcon = @otherHomeIcon
        if listing_status == "Active" then myIcon = @activeHomeIcon

        houseMarker = L.marker [lat, lon],
            icon: myIcon
            dataKey: dataKey
            delegate: delegate
            options:
                testValue: 123

        houseMarker.addTo @map
        houseMarker.bindLabel labelText
        @allPoints.push(houseMarker)

        houseMarker.on 'mouseover', (e) =>
            e.target.options.delegate["onHouseMarker"](e.target.options.dataKey)

        houseMarker.on 'mouseout', (e) =>
            e.target.options.delegate["onHouseMarkerOut"](e.target.options.dataKey)

        @setupMapLinks()
        return houseMarker

    ##|
    ##|  Make a callback and pass in a popupmenu object
    ##|
    setupContextMenu: (@contextMenuTitle, @contextMenuCallbackFunction) =>

        if @contextMenuEventSet != 0
            return true

        @contextMenuEventSet = 1
        @map.on "contextmenu", (obj) =>

            obj.originalEvent.preventDefault()
            obj.originalEvent.stopPropagation()

            coords = GlobalValueManager.GetCoordsFromEvent(obj.originalEvent)
            popupMenu = new PopupMenu @contextMenuTitle, coords.x, coords.y
            @contextMenuCallbackFunction popupMenu, obj.latlng.lat, obj.latlng.lng
            true

