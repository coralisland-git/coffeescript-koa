##|  Function for switching the app to different screens and also contains
##|  navigation button values.

Screens = {}
Screens.history      = []
Screens.current      = 0
Screens.popupVisible = 0

Views        = {}
Scripts      = {}
StyleManager = {}


##|
##|  An instance of the Window Manager anchored in the area that screens will swap
globalWindowManager = null


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

    if Views[viewName]? then return Views[viewName]
    Views[viewName] = new Promise (resolve, reject) ->

        doLoadScript("/views/View" + viewName + ".js")
        .then ()->
            ##|
            ##|  view script is loaded

            if window[className]?
                view = new window[className]

                depList = view.getDependencyList()
                doLoadDependencies(depList)
                .then ()->
                    resolve(view)

            else
                console.log "Unable to find view: ", className

doAppendView = (viewName, holderElement) ->

    appendView = (className, resolve)->
        view = new window[className]()
        view.AddToElement(holderElement)
        view.once "view_ready", ()->
            resolve(view)

    new Promise (resolve, reject) ->

        className = "View" + viewName
        # console.log "Loading class #{className}"

        ##|
        ##|  See if the class is already loaded
        if window[className]?
            appendView(className, resolve)
            return

        if !window.busyLoadingView?
            window.busyLoadingView = {}

        if window.busyLoadingView[viewName]?

            ##|
            ##|  Already loading the existing view
            ##|
            new Promise (resolve, reject)=>
                window.busyLoadingView[viewName].push(resolve)
            .then ()=>
                appendView(className, resolve)

        else

            window.busyLoadingView[viewName] = []
            doLoadView(viewName)
            .then (view)->
                r() for r in window.busyLoadingView[viewName]
                delete window.busyLoadingView[viewName]
                appendView(className, resolve)

##|
##|  Popup a view and then return control to the caller
doPopupView = (viewName, title, settingsName, w, h) ->

    new Promise (resolve, reject) ->

        doLoadView(viewName)
        .then (view)->
            view.windowTitle = title
            view.showPopup settingsName, w, h
            view.once "view_ready", ()->
                view.onSetupButtons()
                resolve(view)

doPopupTableView = (data, title, settingsName, w, h) ->

    new Promise (resolve, reject) ->
        vertical = false
        table_name = title.split(' ').join('_')

        if Array.isArray data
            vertical = false
        else if typeof data == 'object'
            vertical = true
            

        doPopupView 'PopupTable', title, settingsName, w, h
        .then (view) ->
            if vertical == true
                DataMap.removeTableData table_name
                DataMap.importDataFromObjects table_name, data    
                view.loadTable table_name, vertical
            else
                for id, rec of data
                    DataMap.addDataUpdateTable table_name, id, rec
                view.loadTable table_name, vertical

            resolve view


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

##|
##|  Similar to showScreen except that it loads a view as full screen.
##|
showViewAsScreen = (viewName, optionalArgs) ->

    new Promise (resolve, reject)=>

        ##|
        ##|  If the view holder screen isn't loaded yet, load it and then
        ##|  call this function again which will skip this part.
        if not Screens["ViewHolder"] and typeof window["ScreenViewHolder"] isnt "function"
            doLoadScreen "ViewHolder", null
            .then ()->
                resolve(showViewAsScreen(viewName, optionalArgs))
                return true
            return true

        ##|
        ##|  Screen must already be loaded
        doLoadView(viewName)
        .then (view)=>
            showScreen "ViewHolder",
                view: view
                viewName: viewName
                args: optionalArgs

            view.once "view_ready", ()->
                view.popup = Screens["ViewHolder"]
                resolve(view)

            view.showInDiv "ViewHolderContent"

showScreen = (screenName, optionalArgs) ->

    className = "Screen#{screenName}"
    if not Screens[screenName] and typeof window[className] isnt "function"

        doLoadScreen screenName, optionalArgs
        .then (loaded)->
            doShowScreen(screenName, optionalArgs)

    else

        doShowScreen(screenName, optionalArgs)

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
    activateCurrentScreen(optionalArgs, screenName);
    return

activateCurrentScreen = (optionalArgs, screenName) ->

    ##
    ## The screens are setup such that the buttons and other events are not
    ## initialized until the screen is shown the first time.  This allows rarely used
    ## screens to initialize later and makes the app startup faster.
    if not Screens.current.initialized
        Screens.current.onSetupButtons()
        Screens.current.initialized = true

    ##
    ## Allow the screen to make any changes before goint live on the display
    doReplaceScreenContent(screenName)
    Screens.current.onResetScreen()

    w = $(window).width()
    h = $(window).height()
    globalTableEvents.emitEvent "resize", [w, h]
    window.scrollTo 0, 0
    Screens.current.onShowScreen(optionalArgs)

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
    return
