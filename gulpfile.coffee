path        = require 'path'
gulp        = require 'gulp'
gutil       = require 'gulp-util'
coffee      = require 'gulp-coffee'
map         = require 'gulp-sourcemaps'
watch       = require 'gulp-watch'
plumber     = require 'gulp-plumber'
mocha       = require 'gulp-mocha'
del         = require 'del'

# Source map support
require('source-map-support').install()

# Config
# config = require './config'

# Sources
coffee_src    = './coffee/**/*.coffee'
test_src      = './test/**/*.spec.coffee'
main_src      = './coffee/index.coffee'

# Destinations
lib_dst       = 'lib/'
map_dst       = 'map/'

watch_sources = ->
  gulp.watch coffee_src, ['test']

compile_coffee = ->
  gulp.src coffee_src
    .pipe plumber()
    .pipe map.init()
    .pipe coffee(bare: true)
    .pipe map.write('../' + map_dst)
    .on 'error', gutil.log
    .pipe gulp.dest(lib_dst)

gulp.task 'clean', (cb) ->
  del [lib_dst, browser_dst, map_dst], cb

gulp.task 'coffee', ->
  compile_coffee()

gulp.task 'watch', ->
  watch_sources()

gulp.task 'test', ['coffee'], ->
  gulp.src test_src, read: false
    .pipe mocha(
      reporter: 'spec'
    )

gulp.task 'default', ['coffee', 'test']
