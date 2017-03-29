reporters = require 'testx-jasmine-reporters'

exports.config =
  directConnect: true
  specs: [
    'spec/login*'
    'spec/navigation*'
    'spec/apps*'
    'spec/storage*'
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
    browser.driver.manage().window().maximize()
    testx.objects.add require './objects'
    reporters
      html:
        dir: 'tests/results/html'
        showPassed: true
        showStacktrace: true
        showSkipped: true
      junit: false
    beforeEach -> browser.ignoreSynchronization = true
