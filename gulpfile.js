var gulp = require('gulp');
var del = require('del');
var fs = require('fs-plus');
var replace = require('gulp-replace');
var zip = require('gulp-zip');

gulp.task('clean', function(cb) {
    del(['dist'], cb);
});

gulp.task('scripts', ['clean'], function() {
    return gulp.src("client-src/js/**/*.js")
        .pipe(gulp.dest('dist/build/js'));
});

gulp.task('images', ['clean'], function() {
    return gulp.src("client-src/images/**/*")
        .pipe(gulp.dest('dist/build/images'));
});

gulp.task('styles', ['clean'], function() {
    return gulp.src("client-src/css/**/*")
        .pipe(gulp.dest('dist/build/css'));
});

gulp.task('frameworks',['clean'],function() {
    fs.copySync(__dirname+"/client-src/frameworks/SketchConsole/Build/Products/Release/SketchConsole.framework",__dirname+"/dist/build/SketchConsole.framework");
});

gulp.task('plugin', ['clean'], function() {
    return gulp.src([
        "client-src/*.sketchplugin",
        "client-src/consoleOptions.json"
    ])
        .pipe(replace("/frameworks/SketchConsole/Build/Products/Release", ""))
        .pipe(gulp.dest('dist/build'));
});

gulp.task('componentsCSS', ['clean'], function() {
    return gulp.src([
        "client-src/bower_components/bootstrap/dist/css/bootstrap.css",
        "client-src/bower_components/bootstrap/dist/css/bootstrap.css.map"
    ]).pipe(gulp.dest('dist/build/css'));
});

gulp.task('fontAwesome', ['clean'], function() {
    gulp.src("client-src/bower_components/fontawesome/css/*").pipe(gulp.dest('dist/build/css/fontawesome/css'));
    gulp.src("client-src/bower_components/fontawesome/fonts/*").pipe(gulp.dest('dist/build/css/fontawesome/fonts'));
});

gulp.task('componentsJS', ['clean'], function() {
    return gulp.src([
        "client-src/bower_components/jquery/dist/jquery.js",
        "client-src/bower_components/angular/angular.js",
        "client-src/bower_components/angular-bootstrap/ui-bootstrap-tpls.js",
        "client-src/bower_components/moment/moment.js",
        "client-src/bower_components/underscore/underscore.js",
        "client-src/bower_components/mustache/mustache.js"
    ]).pipe(gulp.dest('dist/build/js'));
});

gulp.task('index', ['clean'], function() {
    gulp.src(['client-src/index.html'])
        .pipe(replace("./bower_components/bootstrap/dist/css/", "./css/"))
        .pipe(replace("./bower_components/fontawesome/css/", "./css/fontawesome/css/"))
        .pipe(replace("./bower_components/jquery/dist/", "./js/"))
        .pipe(replace("./bower_components/angular/", "./js/"))
        .pipe(replace("./bower_components/angular-bootstrap/", "./js/"))
        .pipe(replace("./bower_components/moment/", "./js/"))
        .pipe(replace("./bower_components/underscore/", "./js/"))
        .pipe(replace("./bower_components/mustache/", "./js/"))
        .pipe(gulp.dest('dist/build'));
});

gulp.task('zip',['frameworks','scripts','styles','plugin','images','componentsCSS','componentsJS','index','fontAwesome'],function() {
    return gulp.src('dist/build/**/*')
        .pipe(zip('Sketch DevTools.zip'))
        .pipe(gulp.dest('dist'));
});

gulp.task('default', ['zip']);
