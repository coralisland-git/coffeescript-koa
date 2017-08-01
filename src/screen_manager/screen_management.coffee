##|  Function for switching the app to different screens and also contains
##|  navigation button values.

DataSetConfig = require 'edgecommondatasetconfig'


Screens = {}
Screens.history      = []
Screens.current      = 0
Screens.popupVisible = 0

Views        = {}
Scripts      = {}
StyleManager = {}
PopupViews   = {}

##|
##|  An instance of the Window Manager anchored in the area that screens will swap
globalWindowManager = null

##|
##|  A global instance of the data formatter
globalDataFormatter = new DataSetConfig.DataFormatter()

##|
##|  Add a style sheet to the main document if it doesn't already exist
registerStyleSheet = (name, content) ->

    if not StyleManager[name]?
        StyleManager[name] = $ "<style type='text/css' id='sheet_#{name}'></style>"
        $("head").append StyleManager[name]

    StyleManager[name].html content
    true

##|
##|  Given HTML content for a screen, put that html content in the DOM
##|  replace it if it already exists
doReplaceScreenContent = (screenName) ->

    htmlContentEscaped = Screens.current.screenContent
    content = unescape(htmlContentEscaped)

    if screenName == "Login"
        el = $(content)
        el.addClass "ScreenContent#{screenName}"
        $("body").append el
    else
        if globalWindowManager == null
            globalWindowManager = new WindowManager("#main-container")

        globalWindowManager.setContent("<div id='#{Screens.current.classid.replace('#','')}' class='ScreenContent#{screenName}'>" + content + "</div>")

    true


##|
##|  Promise to load a list of URLS
##|
doLoadDependencies = (depList) ->

    new Promise (resolve, reject)->

        if !depList? or !depList.length? or depList.length == 0
            resolve(true)
            return

        url = depList.shift()
        doLoadScript url
        .then ()=>
            doLoadDependencies(depList)
        .then ()=>
            resolve(true)

##|
##|  Dynamically load a view from the server
##|  If the view is already loaded, it returns the already loaded class
##|
doLoadView = (viewName) ->

    className = "View" + viewName

    # -gao
    #if Views[viewName]? then return Views[viewName]
    if Views[viewName]? and window[className]?
        return new Promise (resolve, reject) ->
            view = new window[className]
            resolve(view)

    Views[viewName] = new Promise (resolve, reject) ->

        doLoadScript("/views/View" + viewName + ".js")
        .then ()->
            ##|
            ##|  view script is loaded

            if window[className]?
                view = new window[className]

                if window[className].prototype.css?
                    registerStyleSheet "View#{viewName}", window[className].prototype.css

                depList = view.getDependencyList()
                doLoadDependencies(depList)
                .then ()->
                    resolve(view)

            else
                console.log "Unable to find view2: ", className

##|
##|  Popup a view and then return control to the caller
##|  Returns a promise that resolves to the PopupWindow object
##|  Callback with view if passed in.
##|
doPopupView = (viewName, title, settingsName, w, h, callbackWithView) ->

    new Promise (resolve, reject) ->

        win = new PopupWindow title, 0, 0,
            w: w
            h: h
            scrollable: false
            table_name: settingsName
            keyValue: title

        win.getBody().setView viewName, (view)->
            win.view = view
            view.popup = win
            if callbackWithView? and typeof callbackWithView == "function"
                callbackWithView(view)

            resolve(win)

doPopupTableView = (data, title, settingsName, w, h) ->

    new Promise (resolve, reject) ->
        vertical = false
        table_name = title.split(' ').join('_')

        if Array.isArray data
            vertical = false
        else if typeof data == 'object'
            vertical = true
            

        doPopupView 'PopupTable', title, settingsName, w, h, (view)->
            if vertical == true
                DataMap.removeTableData table_name
                DataMap.importDataFromObjects table_name, data    
                view.loadTable table_name, vertical
            else
                for id, rec of data
                    DataMap.addDataUpdateTable table_name, id, rec
                view.loadTable table_name, vertical

            resolve view

## - xg
## - Popup a view with DynamicTabs, only once
doPopupViewOnce = (viewName, title, settingsName, w, h, tabName, callbackWithView) ->

    newPromise ()->

        if !PopupViews[title]?
            PopupViews[title] = yield doPopupView "DynamicTabs", title, settingsName, w, h
            PopupViews[title].tabNames = []

        if !PopupViews[title].isVisible
            PopupViews[title].open()

        if !PopupViews[title].tabNames.includes(tabName)
            PopupViews[title].tabNames.push tabName
            v = yield PopupViews[title].view.doAddViewTab viewName, tabName, callbackWithView

        PopupViews[title].view.show "tab#{PopupViews[title].tabNames.indexOf(tabName)}"
        true

doLoadScreen = (screenName, optionalArgs) ->

    new Promise (resolve, reject) ->

        head = document.head || document.getElementsByTagName("head")[0];

        oScript = document.createElement("script");
        oScript.type = "text/javascript";

        oScript.onerror = (oError)->
            console.log "Script error: ", oError
            resolve(false)

        oScript.onload = ()->
            resolve(true)

        head.appendChild(oScript)
        oScript.src = "/screens/" + screenName + ".js"

showScreen = (screenName, optionalArgs) ->

    new Promise (resolve, reject)->

        className = "Screen#{screenName}"
        if not Screens[screenName] and typeof window[className] isnt "function"

            doLoadScreen screenName, optionalArgs
            .then (loaded)->
                doShowScreen(screenName, optionalArgs)
            .then ()->
                resolve(Screens[screenName])

        else

            doShowScreen(screenName, optionalArgs)
            .then ()->
                resolve(Screens[screenName])

doShowScreen = (screenName, optionalArgs) ->

    $('input').each (idx, el) ->
        $(el).blur()

    afterSlash = ""

    if !window.hashHistory?
        window.hashHistory = []

    if document.location.hash? and document.location.hash.length > 1
        if /\//.test document.location.hash
            parts = document.location.hash.split('/', 2)
            afterSlash = parts[1]
        window.hashHistory.push document.location.hash.replace('#','')

    if screenName.indexOf("/") != -1
        ##|
        ##|  allow showScreen "Screen/Args/Args",
        parts = screenName.split("/")
        screenName = parts.shift()
        afterSlash = parts.join("/")

    ##|
    ##|  Check to see if the screen is loaded
    if not Screens[screenName]

        className = "Screen#{screenName}"
        if typeof window[className] is "function"

            Screens[screenName] = new window[className]

        else

            new ErrorMessageBox "Screen reference error:<br>#{screenName}"
            console.log "Error, unknown screen '#{screenName}'"
            return

    if Screens.current != 0

        Screens.history.push Screens.current
        Screens.current.onHideScreen()
        $(Screens.current.classid).hide()

    Screens.current = Screens[screenName];
    return activateCurrentScreen(optionalArgs, screenName);

activateCurrentScreen = (optionalArgs, screenName) ->

    return new Promise (resolve, reject)=>

        ##
        ## The screens are setup such that the buttons and other evonScreenReadyents are not
        ## initialized until the screen is shown the first time.  This allows rarely used
        ## screens to initialize later and makes the app startup faster.
        if not Screens.current.initialized
            Screens.current.onSetupButtons()
            Screens.current.initialized = true

        if screenName != "Login"
            document.location.hash = screenName

        ##
        ## Allow the screen to make any changes before goint live on the display
        doReplaceScreenContent(screenName)
        Screens.current.onResetScreen()

        w = $(window).width()
        h = $(window).height()
        globalTableEvents.emitEvent "resize", [w, h]
        window.scrollTo 0, 0
        Screens.current.optionalArgs = optionalArgs

        ##
        ## Update the window title

        $("#MainTitle").html(Screens.current.windowTitle);

        if Screens.current.windowSubTitle.length > 0
            $("#SubTitle").html(Screens.current.windowSubTitle);
            $("#SubTitle").show()
            $("#MainTitle").removeClass("alone")
        else
            $("#SubTitle").hide()
            $("#MainTitle").addClass("alone")

        $(Screens.current.classid).show();
        Screens.current.getScreenSize()
        Screens.current.onShowScreen()
        resolve(true)
