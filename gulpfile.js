var gulp = require('gulp');
var del = require('del');

gulp.task('clean', function(cb) {
    // You can use multiple globbing patterns as you would with `gulp.src`
    del(['dist'], cb);
});

gulp.task('default', function() {
    console.log("I'm alive! :)");
});