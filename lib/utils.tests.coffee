{ assert } = require 'meteor/practicalmeteor:chai'
{ AppDef } = require './utils'

testAppDef =
  def: """
    name: ava
    version: rocketchat

    ava:
      image: ictu/rocketbot:1
      environment:
        - EXPRESS_PORT=5000
        - ROCKETCHAT_URL=http://rocketchat.isd.ictu
        - ROCKETCHAT_ROOM=iqt-integration
        - LISTEN_ON_ALL_PUBLIC=true
        - ROCKETCHAT_USER=ava
        - ROCKETCHAT_PASSWORD=pat3qrC8B5hqnxnS
        - ROCKETCHAT_AUTH=password
        - BOT_NAME=ava
        - RESPOND_TO_DM=true
        - JENKINS_URL=http://www.jenkins.infra.ictu:8080
        - SEMANTIQL_URL=http://www.semantiql.infra.ictu
        - MONGO_URL=mongodb://10.25.88.240:27017/meteor
        - ADMINS=gakoj,giren,jepee
"""

expected =
  bigboatCompose: """
    name: ava
    version: rocketchat

  """
  dockerCompose: """
    ava:
      image: ictu/rocketbot:1
      environment:
        - EXPRESS_PORT=5000
        - ROCKETCHAT_URL=http://rocketchat.isd.ictu
        - ROCKETCHAT_ROOM=iqt-integration
        - LISTEN_ON_ALL_PUBLIC=true
        - ROCKETCHAT_USER=ava
        - ROCKETCHAT_PASSWORD=pat3qrC8B5hqnxnS
        - ROCKETCHAT_AUTH=password
        - BOT_NAME=ava
        - RESPOND_TO_DM=true
        - JENKINS_URL=http://www.jenkins.infra.ictu:8080
        - SEMANTIQL_URL=http://www.semantiql.infra.ictu
        - MONGO_URL=mongodb://10.25.88.240:27017/meteor
        - ADMINS=gakoj,giren,jepee
  """


describe 'AppDef', ->
  describe 'toCompose', ->
    toCompose = AppDef.toCompose
    it 'should work', ->
      actual = toCompose testAppDef
      assert.equal actual.dockerCompose, expected.dockerCompose
      assert.equal actual.bigboatCompose, expected.bigboatCompose
