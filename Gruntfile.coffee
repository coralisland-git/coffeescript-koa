##|
##|  The Grunt task file
##|  Created by Brian Pollack
##|

fs = require 'fs'

##|
##|  Dynamic functions that return a list of files to build
##|  this includes custom output for each module
##|

getModules = ()->
	try
		files = fs.readdirSync "module/"
		return files
	catch e
		console.log "getModule error: ", e
		process.exit(0)

getStylusFiles = ()->
	list =
		'ninja/ninja.css': ['src/**/*styl']
		'ninja/test/ninja.css': ['src/**/*styl']
		'ninja/test/css/test.css': ['test/css/*styl']

	for i in getModules()
		list["ninja/module_#{i}.css"] = ["module/#{i}/*styl"]

	list

getCoffeeFiles = ()->
	list =
		"ninja/ninja.js": ['src/**/*coffee']
		"ninja/test/ninja.js": ['src/**/*coffee']
		"ninja/test/js/test_common.js": ["test/js/test_common.coffee", "test/js/test_data/*coffee"]

	for i in fs.readdirSync "test/js/"
		if !/coffee/.test i then continue
		if /test_common/.test i then continue
		js = i.replace ".coffee", ".js"
		list["ninja/test/js/#{js}"] = ["test/js/#{i}"]

	for i in getModules()
		list["ninja/module_#{i}.js"] = ["module/#{i}/*coffee", "module/#{i}/*.js"]

	return list

module.exports = (grunt) ->
	grunt.initConfig

		##|
		##|  Here is a task for a clean build of everything
		clean:
			build: ['build']

		express:
			internalServer:
				options:
					port: 9000
					hostname: "0.0.0.0"
					bases: ["ninja/test", "doc", "."]

		##|
		##|  Copy task, takes all the files in the different build folders
		##|  produces the final "public" version for consumption
		##|  merging resources from different frameworks
		##|
		copy:
			images:
				files: [
					cwd: 'test/images/'
					src: '*'
					dest: 'ninja/test/images/'
					flatten: true
					filter: 'isFile'
					expand: true
				,
					cwd: 'test/fonts/'
					src: '*'
					dest: 'ninja/test/fonts/'
					flatten: true
					filter: 'isFile'
					expand: true
				,
					cwd: 'test/vendor/'
					src: '*'
					dest: 'ninja/test/vendor/'
					flatten: true
					filter: 'isFile'
					expand: true
				,
					cwd: 'test/vendor/ace/'
					src: '**'
					dest: 'ninja/test/vendor/ace/'
					expand: true
				,
					cwd: 'test/js/test_data/'
					src: '*.json'
					dest: 'ninja/test/js/test_data/'
					flatten: true
					filter: 'isFile'
					expand: true
				]

		##|
		##|  Compile the stylus templates, jade templates, and coffeescript files.
		##|
		stylus:
			compile:
				options:
					paths: ['src/css/', 'test/css/']
					use: [require 'fluidity']
					urlfunc: 'url'
					compress: false
				files: getStylusFiles()

		jade:
			compile:
				options:
					pretty: true
				files:
					"ninja/test/index.html": ["test/views/index.jade"]
					"ninja/test/error.html": ["test/views/error.jade"]

		coffee:
			options:
				bare: true
				sourceMap: true

			compile:
				files: getCoffeeFiles()

		watch:
			grunt:
				files: ['Gruntfile.coffee']

			all:
				files: ['src/css/*.styl', "test/css/*.styl", "module/**/*.styl"]
				tasks: ['stylus:compile']

			coffeeFile:
				files: ['src/**/*coffee', "test/js/*coffee", "test/js/test_data/*coffee", "module/**/*coffee", "module/**/*.js"]
				tasks: ['coffee']

			jadefiles:
				files: ['test/views/*.jade']
				tasks: ['jade:compile']
				options:
					livereload: true

			cssfiles:
				files: ['ninja/ninja.css']
				options:
					livereload: true

			combined:
				files: ['ninja/ninja.js']
				options:
					livereload: true

		bower_concat:
			all:
				dest: 'ninja/bower.js'
				exclude: [
					'jquery'
				]


		##|
		##|  Load all available modules
		require('load-grunt-tasks')(grunt);

		##|
		##|  Build options
		##|
		grunt.registerTask "bower", ['bower_concat']
		grunt.registerTask "server", ['express', 'watch']
		grunt.registerTask 'dist', ['coffee', 'copy', 'stylus', 'jade']
		grunt.registerTask 'synclive', ['buildnumber', 'coffee', 'copy', 'stylus:compile', 'jade:compile', 'shell:synclive']
		grunt.registerTask 'default', ['bower_concat', 'coffee', 'copy', 'stylus:compile', 'jade:compile', 'express', 'watch']
		grunt.registerTask 'build', ['bower_concat', 'coffee', 'copy', 'stylus:compile', 'jade:compile' ]

