{ assert, expect } = require 'meteor/practicalmeteor:chai'
SshContainer = require './ssh-container'

assertBasicProperties = (config) ->
  expect(config, 'Configuration object').to.be.a('object')
  assert.equal config.image, 'jeroenpeeters/docker-ssh'
  assert.equal config.container_name, 'projectName-instanceName-serviceName-ssh'
  assert.equal config.environment.CONTAINER, 'projectName-instanceName-serviceName'
  assert.equal config.labels['bigboat.instance.name'], 'instanceName'
  assert.equal config.labels['bigboat.service.name'], 'serviceName'
  assert.equal config.labels['bigboat.service.type'], 'ssh'
  assert.equal config.labels['bigboat.container.map_docker'], 'true'
  assert.equal config.restart, 'unless-stopped'

describe 'SshContainer', ->
  describe 'buildComposeConfig', ->
    it 'should not return any configuration when enable_ssh or ssh is not present', ->
      config = SshContainer.buildComposeConfig 'projectName', 'instanceName', 'serviceName', {}
      assert.equal config, undefined

    it 'should return default configuration when `enable_ssh` is true (backwards compatibility)', ->
      config = SshContainer.buildComposeConfig 'projectName', 'instanceName', 'serviceName', enable_ssh: true
      assertBasicProperties config
      assert.equal config.environment.AUTH_MECHANISM, 'noAuth'
      assert.equal config.environment.HTTP_ENABLED, 'false'
      assert.equal config.environment.CONTAINER_SHELL, 'bash'

    it 'should return default configuration when `ssh` is true', ->
      config = SshContainer.buildComposeConfig 'projectName', 'instanceName', 'serviceName', enable_ssh: true
      assertBasicProperties config
      assert.equal config.environment.AUTH_MECHANISM, 'noAuth'
      assert.equal config.environment.HTTP_ENABLED, 'false'
      assert.equal config.environment.CONTAINER_SHELL, 'bash'

    it 'should allow to customize the shell', ->
      config = SshContainer.buildComposeConfig 'projectName', 'instanceName', 'serviceName', ssh: shell: '/bin/sh'
      assertBasicProperties config
      assert.equal config.environment.AUTH_MECHANISM, 'noAuth'
      assert.equal config.environment.HTTP_ENABLED, 'false'
      assert.equal config.environment.CONTAINER_SHELL, '/bin/sh'

    it 'should allow to set authentication credentials', ->
      config = SshContainer.buildComposeConfig 'projectName', 'instanceName', 'serviceName', ssh: users: {user1: 'passw1', user2: 'passw2'}
      assertBasicProperties config
      assert.equal config.environment.AUTH_MECHANISM, 'multiUser'
      assert.equal config.environment.HTTP_ENABLED, 'false'
      assert.equal config.environment.CONTAINER_SHELL, 'bash'
      assert.equal config.environment.AUTH_TUPLES, 'user1:passw1;user2:passw2'

    it 'should give presidence to `ssh` when both `enable_ssh` and `ssh` are defined',->
      config = SshContainer.buildComposeConfig 'projectName', 'instanceName', 'serviceName', ssh: {shell: 'someshell'}, enable_ssh: true
      assertBasicProperties config
      assert.equal config.environment.CONTAINER_SHELL, 'someshell'
