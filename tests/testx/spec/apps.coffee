url = require 'url'
randId = Math.floor(Math.random() * 100) + 1

[..., domain, tld] = (url.parse browser.baseUrl).hostname.split('.')

testAppDef =
  testApp: "test-app-#{randId}"
  testVer: "test-ver-#{randId}"
  testName: "test-inst-#{randId}"
  domain: domain
  dockerImage: "ictu/parrot"

describe 'Applications', ->
  it 'should be able to create a new application definition', ->
    testx.run 'tests/testx/scripts/apps/createAppDef.testx', testAppDef
  it 'should be able to update an application definition', ->
    testx.run 'tests/testx/scripts/apps/updateAppDef.testx', testAppDef
  it 'should be able to start a newly defined application', ->
    testx.run 'tests/testx/scripts/apps/startApp.testx', testAppDef
  it 'should be running and have connectivity to each other', ->
    testx.run 'tests/testx/scripts/apps/checkApp.testx', testAppDef
  it 'should be able to stop an application', ->
    testx.run 'tests/testx/scripts/instances/stop.testx', testAppDef
  it 'should be able to delete an application definition', ->
    testx.run 'tests/testx/scripts/apps/deleteAppDef.testx', testAppDef
