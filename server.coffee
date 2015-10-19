express = require 'express'
stylus  = require 'stylus'
nib     = require 'nib'
logger  = require 'morgan'

# Create app instance.
app = express()

app.set 'views', __dirname + '/test/views/'
app.set 'view engine', 'jade'

##|
##|  Setup logging
app.use logger('dev')

##|
##|  Setup stylus
app.use '/css', stylus.middleware
    src: __dirname + '/test/css/'
    compile: (str, path) =>
        return stylus(str).set('filename', path)

app.use express.static(process.cwd() + '/test/')

app.get '/', (req, res) ->
    res.render 'index'

app.listen 3100
console.log "Now live on http://localhost:3100/"

