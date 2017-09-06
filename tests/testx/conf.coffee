reporters = require 'testx-jasmine-reporters'

exports.config =
  # directConnect: true
  specs: [
    'spec/login*'
    'spec/navigation*'
    'spec/apps*'
    'spec/storage*'
    'spec/api*'
  ]

  capabilities:
    browserName: 'chrome'
    shardTestFiles: false
    maxInstances: 2


  framework: 'jasmine'
  jasmineNodeOpts:
    silent: true
    showColors: true
    defaultTimeoutInterval: 300000
    includeStackTrace: true

  baseUrl: 'http://localhost:3000'

  onPrepare: ->
    require 'testx'
    browser.driver.manage().window().setSize 1280, 1080
    testx.keywords.add require 'testx-http-keywords'
    testx.objects.add require './objects'
    reporters
      html:
        dir: 'tests/results/html'
        showPassed: true
        showStacktrace: true
        showSkipped: true
      junit: false
    beforeEach -> browser.ignoreSynchronization = true
  # onComplete: ->
  #   # save coverage info
  #   browser.executeScript '''
  #     Meteor.sendCoverage(function(stats,err) {console.log(stats,err);});
  #     Meteor.exportCoverage("html", function(err) {console.log(err)})
  #   '''
