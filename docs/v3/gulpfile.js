var gulp = require('gulp');
var exec = require('child_process').exec;
var webserver = require('gulp-webserver');
var checkPages = require("check-pages");

function displayErrors(err, stdout, stderr) {
  if (err != undefined) {
    console.log("\nERROR FOUND\n\n" + err);
    console.log("\nDUMPING STDOUT\n\n" + stdout);
    console.log("\nDUMPING STDERR\n\n" + stderr);
    process.exit();
  }
}

gulp.task('middleman', function(cb) {
  exec('bundle exec middleman build', function(err, stdout, stderr) {
    if (err) return displayErrors(err, stdout, stderr);
    cb();
  });
});

gulp.task('webserver', ['middleman'], function() {
  gulp.src('build').pipe(webserver({
    livereload: true
  }));
});

gulp.task('watch', function() {
  gulp.watch(['source/**/*'], ['middleman']);
});

gulp.task('default', ['middleman', 'webserver', 'watch']);


var checkPagesOptions = {
  pageUrls: [
    'http://localhost:8000/'
  ],
  checkLinks: true,
  summary: true,
  terse: true
};

var checkPathAndExit = function(path, options) {
  var stream = gulp.src(path).pipe(webserver({
    livereload: false
  }));

  return checkPages(console, options, function(err, stdout, stderr) {
    stream.emit("kill");

    if (err != undefined) {
      return process.exit("1"); // checkPages found an issue
    } else {
      return true;
    }
  });
};

gulp.task("checkV3docs", ["middleman"], function(cb) {
  checkPagesOptions.linksToIgnore = ["http://localhost:8000/version/release-candidate"];

  checkPathAndExit("build", checkPagesOptions);

});

gulp.task("checkV2docs", [], function(cb) {
  checkPathAndExit("../v2", checkPagesOptions);
});

gulp.task("checkdocs", ["checkV2docs", "checkV3docs"], function(cb) {});
