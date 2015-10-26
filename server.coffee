express = require 'express'
stylus  = require 'stylus'
nib     = require 'nib'
logger  = require 'morgan'
coffee  = require 'coffee-script'
fs      = require 'fs'

withPrettyErrors = (fn) ->
	(code, options = {}) ->
		try
			fn.call @, code, options
		catch err
			throw err if typeof code isnt 'string'
			throw helpers.updateSyntaxError err, code, options.filename

# Create app instance.
app = express()

app.set 'views', __dirname + '/test/views/'
app.set 'view engine', 'jade'

##|
##|  Setup logging
app.use logger('dev')

app.use (req, res, next) =>
	req.headers['if-none-match'] = 'no-match-for-this'
	next()

##|
##|  Setup stylus
app.use '/css', stylus.middleware
	src: __dirname + '/test/css/'
	compile: (str, path) =>
		return stylus(str).set('filename', path)


runScript = (coffeeFile, response) ->
	file = fs.readFile coffeeFile, (err, data) ->
		try
			return next() if err?
			js = coffee.compile data.toString(),
				bare: true
			response
				.contentType('text/javascript')
				.send js
		catch e

			console.log "Exception in file #{coffeeFile}", e
			response.send "console.log('Exception in file #{coffeeFile}: ');"


app.use '/test/js', (request, response, next) ->
	coffeeFile = __dirname + "/test/js/" + request.path.replace ".js", ".coffee"
	runScript coffeeFile, response


app.use '/js', (request, response, next) ->
	coffeeFile = __dirname + "/src/" + request.path.replace ".js", ".coffee"
	runScript coffeeFile, response

app.use express.static(process.cwd() + '/test/')

app.get '/', (req, res) ->
	res.render 'default', (err, html) ->
		res.render 'index',
			page: html

app.get '*', (req, res) ->
	strName = req.path.replace('/', '')
	res.render strName, (err, html) ->
		res.render 'index',
			page: html

app.listen 3100
console.log "Now live on http://localhost:3100/"

