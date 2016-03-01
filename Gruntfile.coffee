##|
##|  The Grunt task file
##|  Created by Brian Pollack
##|

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
					bases: [ "ninja/test/" ]

		##|
		##|  Copy task, takes all the files in the different build folders
		##|  produces the final "public" version for consumption
		##|  merging resources from different frameworks
		##|
		copy:

			images:
				files : [
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
					use: [ require 'fluidity' ]
					urlfunc: 'url'
					compress: false
				files:
					'ninja/ninja.css'          : [ 'src/**/*styl' ]
					'ninja/test/ninja.css'     : [ 'src/**/*styl' ]
					'ninja/test/css/test.css'  : [ 'test/css/*styl' ]

		jade:
			compile:
				options:
					pretty: true
				files:
					"ninja/test/index.html"                : [ "test/views/index.jade" ]
					"ninja/test/error.html"                : [ "test/views/error.jade" ]

		coffee:
			options:
				bare:		true
				sourceMap:	true

			compile:
				files:
					"ninja/ninja.js"                        : [ 'src/**/*coffee' ]
					"ninja/test/ninja.js"                   : [ 'src/**/*coffee' ]
					"ninja/test/js/address_normalizer_1.js" : [ "test/js/address_normalizer_1.coffee" ]
					"ninja/test/js/data_mapper_1.js"        : [ "test/js/data_mapper_1.coffee" ]
					"ninja/test/js/dialog_1.js"             : [ "test/js/dialog_1.coffee" ]
					"ninja/test/js/dynamic_data_1.js"       : [ "test/js/dynamic_data_1.coffee" ]
					"ninja/test/js/dynamic_data_2.js"       : [ "test/js/dynamic_data_2.coffee" ]
					"ninja/test/js/dynamic_data_3.js"       : [ "test/js/dynamic_data_3.coffee" ]
					"ninja/test/js/popup_menu_1.js"         : [ "test/js/popup_menu_1.coffee" ]
					"ninja/test/js/popup_window_1.js"       : [ "test/js/popup_window_1.coffee" ]
					"ninja/test/js/tables_1.js"             : [ "test/js/tables_1.coffee" ],
					"ninja/test/js/tables_2.js"             : [ "test/js/tables_2.coffee" ]
					"ninja/test/js/test_common.js"          : [ "test/js/test_common.coffee", "test/js/test_data/*coffee" ]

		watch:

			grunt:
				files:	['Gruntfile.coffee']

			all:
				files:	['src/css/*.styl', "test/css/*.styl"]
				tasks:	['stylus:compile']

			coffeeFile:
				files:	['src/**/*coffee', "test/js/*coffee", "test/js/test_data/*coffee" ]
				tasks:	['coffee']

			jadefiles:
				files:	['test/views/*.jade']
				tasks:	['jade:compile']
				options:
					livereload: true

			cssfiles:
				files:	['ninja/ninja.css']
				options:
					livereload: true

			combined:
				files:	['ninja/ninja.js']
				options:
					livereload: true


		##|
		##|  External modules
		##|
		grunt.loadNpmTasks 'grunt-contrib-coffee'
		grunt.loadNpmTasks 'grunt-contrib-jade'
		grunt.loadNpmTasks 'grunt-contrib-watch'
		grunt.loadNpmTasks 'grunt-contrib-copy'
		grunt.loadNpmTasks 'grunt-contrib-stylus'
		grunt.loadNpmTasks 'grunt-notify'
		grunt.loadNpmTasks 'grunt-express'


		grunt.registerTask "server",  	['express', 'watch']
		grunt.registerTask 'dist', 		['coffee', 'copy', 'stylus', 'jade']
		grunt.registerTask 'synclive', 	['buildnumber', 'coffee', 'copy', 'stylus:compile', 'jade:compile', 'shell:synclive']
		grunt.registerTask 'default', 	['coffee', 'copy', 'stylus:compile', 'jade:compile', 'express', 'watch']


