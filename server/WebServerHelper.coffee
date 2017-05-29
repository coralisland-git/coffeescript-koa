mime                = require 'mime-types'
glob                = require 'glob-all';
stylus              = require 'stylus'
nib                 = require 'nib'
pug                 = require 'pug'
fs                  = require 'fs'
less                = require 'less'
os                  = require 'os'
chalk               = require 'chalk'
coffeeScript        = require 'coffee-script'
{updateSyntaxError} = require 'coffee-script/lib/coffee-script/helpers'


##|
##|  Helper function
module.exports =
class WebServerHelper

    ##|
    ##|  Given a filename and path list, resolve with the full path that exists.
    ##|
    @doFindFileInPath: (filename, pathList)->

        new Promise (resolve, reject)->

            if typeof pathList == "string" then pathList = [ pathList ]
            for path in pathList

                try
                    filenameTest = path + filename
                    stat = fs.statSync filenameTest
                    if stat? and stat.size
                        resolve(filenameTest)
                        return true

                catch e
                    # ...

            console.log "File #{filename} not found in [", pathList.join(","), "]"
            resolve null


    @doCompileLessFiles : (filenameList)->

        new Promise (resolve, reject)->

            try

                strContent = ""
                for filename in filenameList
                    strContent += fs.readFileSync filename

                less.render strContent, { compress: false }, (err, output) =>

                    if err?
                        console.log "LESS Compile Error:", err

                    resolve(output)

            catch e

                console.log "doCompileLessFile, file not found #{filenameList}"
                resolve("")


    @doCompileStylusFile : (filename)->

        new Promise (resolve, reject)->

            if !filename?
                resolve("")
                return

            fs.readFile filename, 'utf8', (err, content)->

                try
                    stylus(content)
                    .set("filename", filename)
                    .set("compress", false)
                    .use(nib())
                    .render (err, css)=>
                        if err?
                            console.log chalk.yellow("Error in Stylus file: ") + filename
                            console.log err
                            resolve("")
                        else

                            resolve(css)

                catch ex
                    if !content?
                        console.log "No such file: #{filename}"
                    else
                        console.log "Filename=#{filename} Content=", content
                        console.log "Inner exception from Stylus: ", chalk.yellow(ex)

                    resolve(null)


    @doCompilePugFile : (filename)->

        new Promise (resolve, reject)->

            if !filename?
                resolve("")
                return

            try

                fs.readFile filename, 'utf8', (err, content)->

                    if err?
                        resolve("")
                        return

                    html = pug.render content,
                        filename : filename
                        pretty   : false
                        debug    : false
                        buildnum : 1
                        ioserver : os.hostname() + ":" + 9000

                    resolve(html)

            catch e

                console.log "Unable to compile Pug: ", filename
                resolve("")

    @doCompileCoffeeFile : (filename, createMap = null)->

        new Promise (resolve, reject)->

            # console.log "Reading File:", filename, typeof filename

            fs.readFile filename, 'utf8', (err, content)->

                try

                    if createMap? and createMap

                        compiled = coffeeScript.compile content,
                            bare: true
                            sourceMap: true

                        resolve(compiled)

                    else
                        compiled = coffeeScript.compile content,
                            bare: true
                        resolve(compiled)

                catch ex

                    console.log "Content=", content
                    console.log "[filename=#{filename}] Inner exception from CoffeeScript: ", ex.toString()
