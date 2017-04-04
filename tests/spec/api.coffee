randId = Math.floor(Math.random() * 100) + 1

testAppDef =
  apiKey: "27c6ee43cc29095b5c80e91d9e7fa735"
  testApp: "test-app-api-#{randId}"
  testVer: "test-ver-api-#{randId}"
  testName: "test-inst-api-#{randId}"

describe 'API v2', ->
  it 'should be able to create a new application definition', ->
    testx.run 'tests/scripts/api/createAppDef.testx', testAppDef
  # it 'should be able to update an application definition', ->
  #   testx.run 'tests/scripts/api/updateAppDef.testx', testAppDef
  # it 'should be able to start an instance', ->
  #   testx.run 'tests/scripts/api/startApp.testx', testAppDef
  # it 'should be able to stop an instance', ->
  #   testx.run 'tests/scripts/api/stopInstance.testx', testAppDef
  it 'should be able to delete an application definition', ->
    testx.run 'tests/scripts/api/deleteAppDef.testx', testAppDef
