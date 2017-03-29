randId = Math.floor(Math.random() * 100) + 1

testAppDef =
  testApp: "test-app-#{randId}"
  testVer: "test-ver-#{randId}"
  testName: "test-inst-#{randId}"

describe 'Applications', ->
  it 'should be able to create a new application definition', ->
    testx.run 'tests/scripts/apps/createAppDef.testx', testAppDef
  it 'should be able to update an application definition', ->
    testx.run 'tests/scripts/apps/updateAppDef.testx', testAppDef
  it 'should be able to start a newly defined application', ->
    testx.run 'tests/scripts/apps/startApp.testx', testAppDef
  it 'should be able to stop an application', ->
    testx.run 'tests/scripts/instances/stop.testx', testAppDef
  it 'should be able to delete an application definition', ->
    testx.run 'tests/scripts/apps/deleteAppDef.testx', testAppDef
