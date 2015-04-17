gulp = require('gulp')
gutil = require('gulp-util')
merge = require('ordered-merge-stream')
path = require('path')

jade = require('gulp-jade')
concat = require('gulp-concat')
uglify = require('gulp-uglify')
stylus = require('gulp-stylus')
minifyCss = require('gulp-minify-css')
nib = require('nib')
rupture = require('rupture')

server = require('gulp-server-livereload')



paths = 
  bower: './bower_components'
  src:
    jade: './src/jade/*.jade'
    js: './src/js/*.js'
    stylus: './src/stylus/style.styl'
  watch:
    jade: './src/jade/**/*.jade'
    js: './src/js/**/*.js'
    stylus: './src/stylus/**/*.styl'
  build:
    html: './'
    js: './'
    css: './'


# PureCSS sources
baseCssSrc = [
  path.join paths.bower, 'normalize-css', 'normalize.css'
  path.join paths.bower, 'purecss', 'src', 'base', 'css', "base.css"
  path.join paths.bower, 'purecss', 'src', 'buttons', 'css', "buttons-core.css"
  path.join paths.bower, 'purecss', 'src', 'buttons', 'css', "buttons.css"
  path.join paths.bower, 'purecss', 'src', 'forms', 'css', "form-nr.css"
  path.join paths.bower, 'purecss', 'src', 'forms', 'css', "form-r.css"
  path.join paths.bower, 'purecss', 'src', 'grids', 'css', "grids-core.css"
  path.join paths.bower, 'purecss', 'src', 'grids', 'css', "grids-units.css"
]




gulp.task 'jade', ->
  gulp.src paths.src.jade
    .pipe jade()
    .on 'error', gutil.log
    .pipe gulp.dest(paths.build.html)


gulp.task 'stylus', ->  
  baseCss = gulp.src baseCssSrc
    .pipe concat('base.css')

  appCss = gulp.src paths.src.stylus
    .pipe stylus({
      use: [ nib(), rupture() ]
      compress: false
    })
    .on 'error', gutil.log
    .pipe concat('app.css')

  merge([baseCss, appCss])
    .pipe concat('style.css')
    .pipe minifyCss()
    .on 'error', gutil.log
    .pipe gulp.dest(paths.build.css)



gulp.task 'js', ->
  gulp.src [
    path.join(paths.bower, 'zepto', 'zepto.js')
    paths.src.js
  ]
    .pipe uglify()
    .pipe concat('app.js')
    .pipe gulp.dest(paths.build.js)


gulp.task 'build', ['jade', 'stylus', 'js']


gulp.task 'server', ->
  gulp.src './'
    .pipe server({
      host: 'local.hiddentao.github.io'
      livereload:
        enable: true
        filter: (filePath, cb) ->
          cb( !(/src/).test(filePath) )
      directoryListing: false
      open: false
    })


gulp.task 'dev', ['build', 'server'], ->
  gulp.watch paths.watch.jade, ['jade']
  gulp.watch paths.watch.stylus, ['stylus']
  gulp.watch paths.watch.js, ['js']



gulp.task 'default', ['dev']
