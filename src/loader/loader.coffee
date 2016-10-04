##|
##|  Load a CoffeeNinjaCommon Module
##|  Returns a promise that will complete once the module is loaded.
##|
##|  The promise is cached so that module is loaded once and efficient to call this
##|  function many times for the same module.
##|

##|  Reference to promises for script caching
Scripts = {}

## -------------------------------------------------------------------------------------------------------------
## Load a script, only once.  Then return from the promise after it's loaded
## Safe to call many times for the same script and it quickly returns the already
## resolved promise.
##
## @param url [string] Script to load
##
doLoadScript = (url) ->

    if Scripts[url]?
        return Scripts[url]

    Scripts[url] = new Promise (resolve, reject) ->

        oScript = document.createElement "script"
        oScript.type = "text/javascript"
        oScript.onerror = (oError) ->
            console.log "[#{url}] Script load error:", oError.toString()
            resolve(true)

        oScript.onload = ()->
            # console.log "Script loaded:", url
            resolve(true)

        head = document.head || document.getElementsByTagName("head")[0];
        head.appendChild oScript
        oScript.src = url

