exreport            = require 'coffee-exception-report'
koa                 = require 'koa'
session             = require 'koa-session'
glob                = require('glob-all');
stylus              = require 'stylus'
pug                 = require 'pug'
fs                  = require 'fs'
zlib                = require 'zlib'
coffeeScript        = require 'coffee-script'
{updateSyntaxError} = require('coffee-script/lib/coffee-script/helpers')
mime                = require 'mime-types'
co                  = require 'co'
WebServerHelper     = require './WebServerHelper'
browserify          = require 'browserify'
coffeeify           = require 'coffeeify'

argv = require('yargs')
    .usage('Usage: $0 --gen')
    .demandOption([])
    .argv

SAVE_NINJAFILE_AND_EXIT = (strCSS, strJS) =>
    if !argv.gen then return
    console.log "Writing ../ninja/ninja.css"
    fs.writeFile "../ninja/ninja.css", strCSS, (err, done) ->
        if err? then return console.log "Error writing Ninja.css", err
    console.log "Writing ../ninja/ninja.js"
    fs.writeFile "../ninja/ninja.js", strJS, (err, done) ->
        if err? then return console.log "Error writing Ninja.js:", err
        process.exit(0)

bundle = browserify
  extensions: ['.coffee']

bundle.transform coffeeify,
  bare: true
  header: true

WebPath         = "../ninja/"
server          = null
ninjaJavascript = ""
ninjaCss        = ""

ninjaPathMiddleware = (app)->

    app.use (next)->

        if /ninja.js/.test this.url
            this.set('Content-Encoding', "gzip")
            this.set("Content-Length", ninjaJavascript.length)
            this.response.type = 'application/vnd.api+json'
            this.body = ninjaJavascript
            return true

        if /ninja.css/.test this.url
            this.set('Content-Encoding', "gzip")
            this.set("Content-Length", ninjaCss.length)
            this.response.type = 'text/css'
            this.body = ninjaCss
            return true

        yield next

staticPathMiddleware = (app, folder, url) ->

    ##|
    ##|  Convert a single path to a list of paths.
    if typeof folder == "string"
        folder = [ folder ]

    console.log "Mapped #{folder} to url #{url}"

    rePath = new RegExp "^" + url + "/([^\?]+)", "i"
    app.use (next) ->

        try
            m = this.url.match rePath
            if m?

                for path in folder

                    try
                        filename = path + m[1]
                        # console.log "staticPathMiddleware checking #{filename}"
                        stats = fs.statSync filename
                        if stats?
                            this.response.type = mime.lookup filename
                            this.body = fs.createReadStream filename
                            return true

                    catch e

                        # console.log "Unable to find #{path}/#{m[1]}"

                return false

        catch e
            console.log "Static file error: " + e

        yield next


compileScreen = (screenName, appName)->

    co ()->

        console.log "compileScreen Screen=#{screenName}, appName=#{appName}"

        pathList = [ "../ninja/screens/" ]
        if appName? then pathList = [ "../test/#{appName}/screens/", "../ninja/screens/"]

        filenameStylus = yield WebServerHelper.doFindFileInPath "screen_#{screenName.toLowerCase()}.styl", pathList
        filenamePug   = yield WebServerHelper.doFindFileInPath "screen_#{screenName.toLowerCase()}.pug", pathList
        filenameCoffee = yield WebServerHelper.doFindFileInPath "screen_#{screenName.toLowerCase()}.coffee", pathList

        html = yield WebServerHelper.doCompilePugFile filenamePug
        html = "<div id='Screen#{screenName}' class='screen contentNoPadding overflow-hidden'>" + html + "</div>"
        js   = yield WebServerHelper.doCompileCoffeeFile filenameCoffee

        str = ""
        str += js
        str += "\n"
        str += "Screen#{screenName}.prototype.screenContent = '"
        str += escape(html)
        str += "';"

        ##|
        ##|  CSS File
        css  = yield WebServerHelper.doCompileStylusFile filenameStylus
        if css
            css = escape(css)
            str += "Screen#{screenName}.prototype.css = unescape('#{css}');"

        return str

compileView = (viewName, appName)->

    console.log "compileView viewName=#{viewName}, appName=#{appName}"

    co ()->

        pathList = [ "../ninja/views/" ]
        if appName? then pathList = [ "../test/#{appName}/views/", "../ninja/views/" ]

        filenameCss  = yield WebServerHelper.doFindFileInPath "#{viewName}.styl", pathList
        filenameHtml = yield WebServerHelper.doFindFileInPath "#{viewName}.pug", pathList
        filenameJs   = yield WebServerHelper.doFindFileInPath "#{viewName}.coffee", pathList

        css  = yield WebServerHelper.doCompileStylusFile filenameCss
        html = yield WebServerHelper.doCompilePugFile filenameHtml
        js   = yield WebServerHelper.doCompileCoffeeFile filenameJs

        html = escape(html)
        css  = escape(css)

        js += "\n"
        js += "#{viewName}.prototype.template = unescape('#{html}');\n"
        js += "#{viewName}.prototype.css = unescape('#{css}');"
        js += "\n"

        return js

module.exports =
class NinjaWebServer

    ##|
    ##|  Get the component required for starting Socket.io
    getHttpServer: ()=>
        httpServer = require('http').Server(@app.callback())

    ##|
    ##|  Set a timer to watch a file for changes
    setWatchTimer: (f, callback) =>
        ##|
        ##|  Watch for changes
        if !server.fileWatch[f]?
            server.fileWatch[f] = fs.watch f, {recursive:true}, (event, filename) =>
                console.log "WATCH #{filename}:", event

                if server.fileTimer[f]
                    clearTimeout server.fileTimer[f]
                filename = filename.replace "\\", "/"
                server.fileTimer[f] = setTimeout callback, 1000, filename

        true

    ##|
    ##|  Process a path or glob to a set of files
    ##|  Initialize the static content holder and make a callback for each
    processPath: (url, path, contentType, callbackEachFile) =>

        co ()=>

            console.log "Processing #{path} (#{contentType}) for #{url}"
            files = glob.sync path

            @staticContent[url] =
                mime: contentType
                content: ""

            for f in files

                console.log "processPath #{contentType}: Reading file: #{f} for #{url}"
                content = yield callbackEachFile(f)
                @staticContent[url].content += content

                ##|
                ##|  Watch for changes
                @setWatchTimer f, ()=>
                    server.fileTimer[f] = null
                    console.log "processPath Reloading url=#{url} path=#{path}"
                    @processPath url, path, contentType, callbackEachFile

    loadLessFiles: (url, path) =>

        files = [ WebPath + "css/variables.less", WebPath + "css/mixins.less" ]
        @processPath url, path, "text/css", (filename) =>
            if not /mixins/.test(filename) and not /variables/.test(filename)
                files.push filename

            return new Promise (resolve, reject) =>
                resolve ""

        setTimeout ()=>
            WebServerHelper.doCompileLessFiles files
            .then (css)=>
                @staticContent[url].content = css.css
        , 200


    ##|
    ##| Load a stylus template to a URL
    ##| If that template file changes, recompile and update the url
    ##|
    loadStylusFile: (url, path)=>

        @processPath url, path, "text/css", WebServerHelper.doCompileStylusFile
        true

    loadPugFile: (url, path)=>

        @processPath url, path, "text/html", WebServerHelper.doCompilePugFile
        true

    loadCoffeeFiles: (url, path)=>

        @processPath url, path, "text/javascript", WebServerHelper.doCompileCoffeeFile
        true

    setupStatic: ()=>

        @app.use (next)->

            if server.staticContent[@path]?
                this.response.type = server.staticContent[@path].mime
                this.body = server.staticContent[@path].content
                console.log "setupStatic Static sent #{@path} [", this.response.type, "]"
            else
                yield next

    ##|
    ##|  If there is an app name, pull it out of the URL
    findAppNameMiddleware: ()=>

        reApp = new RegExp "^/([a-zA-Z]+)/*$"

        @app.use (next)->

            m = @url.match reApp
            if m?
                console.log "findAppNameMiddleware Found app ", m[1], " in ", @url
                path = "/"
                this.session.appName = m[1]
                this.response.type = server.staticContent[path].mime
                this.body = server.staticContent[path].content
                return true


            yield next

    dynamicJavascript: ()=>

        @app.use (next)->

            m = @url.match /js\/(.*)\.js/
            if m?
                console.log "Dynamic JS", m[1]

                filename = yield WebServerHelper.doFindFileInPath m[1]+".coffee", ["../test/js/", "../test/js/test_data/"]
                console.log "Filename:", filename

                js = yield WebServerHelper.doCompileCoffeeFile(filename)

                this.set("Content-Length", js.length)
                this.response.type = 'application/vnd.api+json'
                this.body = js
                return true

            yield next

    screenMiddleware: ()=>

        reScreen = new RegExp "^/screens/(.*).js", "i"
        reView   = new RegExp "^/views/(.*).js", "i"

        @app.use (next)->
            m = @url.match reScreen
            if m?
                this.body = yield compileScreen(m[1], this.session.appName)
                this.response.type = "application/javascript"
                return true

            m = @url.match reView
            if m?
                this.body = yield compileView(m[1], this.session.appName)
                this.response.type = "application/javascript"
                return true

            yield next
            true

    rebuildNinjaFile: (file)=>

        getClassInfo = (name)=>

            m1 = @ninjaCoffeeRaw[name].match /class (.*) extends (.*)/
            if m1 then return { class: m1[1], extends: m1[2], name: name }
            return null

        getRequireInfo = (name)=>
            m1 = @ninjaCoffeeRaw[name].match /require (.*)/
            if m1 then return { class: m1[1], useRequire: true, name: name }
            return null

        co ()=>

            if /.coffee/.test file

                output                  = yield WebServerHelper.doCompileCoffeeFile file, true

                @ninjaCoffeeRaw[file]   = fs.readFileSync(file).toString()
                @ninjaCoffeeFiles[file] = output.js
                @ninjaCoffeeMap[file]   = output.v3SourceMap

                info = getClassInfo(file)
                useRequire = getRequireInfo(file)
                if useRequire? and useRequire.useRequire == false
                    bundle.add file
                else if info? and info.extends?
                    for name in @ninjaCoffeeExtends
                        if name == file then return true
                    @ninjaCoffeeExtends.push info
                else
                    for name in @ninjaCoffeeNormal
                        if name == file then return true
                    @ninjaCoffeeNormal.push file
                

            else if /.styl/.test file
                # console.log "Adding stylus file:", file
                css = yield WebServerHelper.doCompileStylusFile file
                @ninjaStylusFiles[file] = css
            else if /.pug/.test file
                html = yield WebServerHelper.doCompilePugFile file
                # console.log "Adding Pug file:", file
                @ninjaPugFiles[file] = html
            else if /\.png|\.jpg/.test file
                # console.log "Adding image file:", file
            else
                return false

    rebuildNinjaSave: ()=>

        str = ""
        for name in @ninjaCoffeeNormal
            str += @ninjaCoffeeFiles[name]
        bundle.require 'edgecommondatasetconfig', {basedir: '../node_modules/'}

        @ninjaCoffeeExtends = @ninjaCoffeeExtends.sort (a, b)->
            return a.name < b.name

        for info in @ninjaCoffeeExtends
            console.log "Extends:", info
            str += @ninjaCoffeeFiles[info.name]

        strCss = ""
        strCss += css for file, css of @ninjaStylusFiles

        ##
        ##--xg
        bundle.bundle (error, result) ->
            throw error if error?
            zlib.gzip result + str, (_, contentJs)=>
                ninjaJavascript = contentJs
            SAVE_NINJAFILE_AND_EXIT(strCss, result.toString() + str)

        zlib.gzip strCss, (_, contentCss)=>
            ninjaCss = contentCss

        for file, html of @ninjaPugFiles
            console.log "Error: what do we do with #{file}"

        true

    rebuildNinja: ()=>
        ##|
        ##|  Scan all the source files in the Ninja folder
        ##|  Compile to ninja.src.coffee and compile that file to javascript
        ##|

        co ()=>

            @ninjaCoffeeExtends = []
            @ninjaCoffeeNormal  = []
            @ninjaCoffeeRaw     = {}
            @ninjaCoffeeFiles   = {}
            @ninjaCoffeeMap     = {}
            @ninjaPugFiles     = {}
            @ninjaStylusFiles   = {}

            files = glob.sync "../src/**"
            yield @rebuildNinjaFile(file) for file in files
            @rebuildNinjaSave()

            @setWatchTimer "../src/.", (filename)=>
                filename = "../src/#{filename}"
                console.log "rebuildNinja change: #{filename}"
                @rebuildNinjaFile(filename)
                .then ()=>
                    console.log "Resaving"
                    @rebuildNinjaSave()


    constructor: () ->

        ##|
        ##| Global reference to server
        server         = this
        @staticContent = {}
        @fileWatch     = {}
        @fileTimer     = {}

        @rebuildNinja()

        @app = koa()

        @app.keys = ['NinjaWebServerKey123'];
        @app.use(session(@app));

        @findAppNameMiddleware()

        @loadStylusFile "/css/test.css", "../test/css/*styl"
        @loadPugFile "/", "../test/template/index.pug"
        @loadPugFile "/index.html", "../test/template/index.pug"

        ninjaPathMiddleware @app

        staticPathMiddleware @app, "../node_modules/mathjs/dist/", "/vendor/mathjs"
        staticPathMiddleware @app, "../node_modules/mathjax/", "/vendor/mathjax"
        staticPathMiddleware @app, "../node_modules/mathjax/extensions/", "/extensions"

        ##|
        ##| Vendor or 3rd party
        staticPathMiddleware @app, "../test/js/test_data/", "/js/test_data"
        staticPathMiddleware @app, "../ninja/vendor/ace/", "/ace"
        staticPathMiddleware @app, "../ninja/vendor/closure/", "/closure"
        staticPathMiddleware @app, "../ninja/vendor/closure/", "/closure-library/closure"
        staticPathMiddleware @app, "../ninja/vendor/blockly/", "/blockly"

        ##|
        ##| Local static files
        staticPathMiddleware @app, ["../ninja/fonts/",  "../test/fonts/" ], "/fonts"
        staticPathMiddleware @app, ["../ninja/images/", "../test/images/" ], "/images"
        staticPathMiddleware @app, ["../ninja/vendor/", "../test/vendor/" ], "/vendor"
        staticPathMiddleware @app, "../../CoffeeNinjaCommon/ninja/", "/ninja"
        staticPathMiddleware @app, ["../doc/",  "../doc/" ], "/doc"

        @dynamicJavascript()
        @setupStatic()
        @screenMiddleware()

        @app.listen(9000)
        console.log "Listening on port #{9000}"
