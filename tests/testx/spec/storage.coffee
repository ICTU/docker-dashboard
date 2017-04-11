testContext =
  bucketName: 'test-bucket'
  copyToName: 'test-bucket-copy'

describe 'Storage', ->
  it 'should be able to create a bucket', ->
    testx.run 'tests/testx/scripts/storage/createBucket.testx', testContext
  it 'should be able to copy a bucket', ->
    testx.run 'tests/testx/scripts/storage/copyBucket.testx', testContext
  it 'should be able to delete a bucket', ->
    testx.run 'tests/testx/scripts/storage/deleteBucket.testx', testContext
