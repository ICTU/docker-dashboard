describe 'Login', ->
  it 'should be mandatory', ->
    testx.run 'tests/testx/scripts/login.testx',
      username: 'iqttestuser'
      password: process.env.TEST_USER_PASS
