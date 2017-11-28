randId = Math.floor(Math.random() * 100) + 1

testAppDef =
  testApp: "test-app-api-#{randId}"
  testVer: "test-ver-api-#{randId}"
  testName: "test-inst-api-#{randId}"
  testBucket: "test-bucket-#{randId}"
  testBucketCopy: "test-bucket-copy-#{randId}"

describe 'API v2', ->
  beforeAll -> # get the API key
    browser.get '/config'
    browser.sleep 1000
    element(protractor.By.id 'inputApi').getAttribute('value').then (val) ->
      if val
        testAppDef.apiKey = val
      else
        testx.run 'tests/testx/scripts/api/generateApiKey.testx'
        browser.sleep 1000
        element(protractor.By.id 'inputApi').getAttribute('value').then (val) ->
          testAppDef.apiKey = val
  it 'should be able to create a new application definition', ->
    testx.run 'tests/testx/scripts/api/createAppDef.testx', testAppDef
  it 'should be able to update an application definition', ->
    testx.run 'tests/testx/scripts/api/updateAppDef.testx', testAppDef
  it 'should be able to start an instance', ->
    testx.run 'tests/testx/scripts/api/startApp.testx', testAppDef
  it 'should be able to stop an instance', ->
    testx.run 'tests/testx/scripts/api/stopInstance.testx', testAppDef
  it 'should be able to delete an application definition', ->
    testx.run 'tests/testx/scripts/api/deleteAppDef.testx', testAppDef
  # it 'should be able to create a new bucket', ->
  #   testx.run 'tests/testx/scripts/api/createBucket.testx', testAppDef
  # it 'should be able to copy a bucket', ->
  #   testx.run 'tests/testx/scripts/api/copyBucket.testx', testAppDef
  # it 'should be able to get list all buckets', ->
  #   testx.run 'tests/testx/scripts/api/listBuckets.testx', testAppDef
  # it 'should be able to delete a bucket', ->
  #   testx.run 'tests/testx/scripts/api/deleteBucket.testx', testAppDef