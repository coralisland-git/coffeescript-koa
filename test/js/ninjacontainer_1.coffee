$ ->

    addTestButton "Simple Widget with HTML", "Open", (e)->
        addHolder().addDiv().html "HTML Set"

    addTestButton "Simple Widget Resize Test", "Open", (e)->
        w = addHolder()

        info = w.addDiv()
        info.css "padding", 10
        info.css "fontSize", "18px"

        ##|  save old event
        superResize = w.onResize

        ##|  intercept onResize which happens after the resize is complete
        w.onResize = (w, h)->
            info.html "My size is now #{w}, #{h}"
            superResize(w, h)

        info.html "Resize the browser or move the splitter to change the size of this test window."

    addHolder().addDiv().html "This page shows examples of the base NinjaContainer which is the base class behind views, widgets, and screens."

    addTestButton "Simple View showing size for comparison", "Open", (e)->

        w = addHolder()
        w.setView "TestShowSize"

    addTestButton "Top Dock Test", "Open", (e)->

        w = addHolder()
        w.setView "Docked", (view)->
            view.getFirst().html "This is a docked widget that will be 100px on the top always"
            view.getBody().setView "TestShowSize"


    addTestButton "Left Dock Test", "Open", (e)->

        w = addHolder()
        w.setView "Docked", (view)->
            view.setLocationName "left"
            view.setDockSize 160
            view.getFirst().html "This is a docked widget that will be 160px on the left always"
            view.getBody().setView "TestShowSize"


    addTestButton "Bottom Dock Test with a view", "Open", (e)->

        w = addHolder()
        w.setView "Docked", (view)->
            view.setLocationName "bottom"
            view.setDockSize 200
            view.getFirst().setView "TestShowSize"
            view.getBody().setView "TestShowSize"

    addTestButton "Simple Popup with a dock on top", "Open", (e)->

        doPopupView "Docked", "Popup with a dock", null, 500, 500, (view)->
            view.getFirst().setView "TestShowSize"
            view.getBody().setView "TestShowSize"

    addTestButton "Simple Popup with a dock on bottom", "Open", (e)->

        doPopupView "Docked", "Popup with a dock", null, 500, 500, (view)->
            view.setLocationName "bottom"
            view.getFirst().setView "TestShowSize"
            view.getBody().setView "TestShowSize"

    addTestButton "Popup Table with dock", "Open", (e)->

        loadZipcodes()
        .then ()->
            doPopupView "Docked", "Popup with a table and dock", null, 500, 600, (view)->
                view.setDockSize 80
                view.getFirst().setView "TestShowSize"
                view.getBody().setView "Table", (viewTable)->
                    viewTable.addTable "zipcode"

    go()