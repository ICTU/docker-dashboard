_ = require 'underscore'

module.exports =
  buildComposeConfig: (project, instance, serviceName, serviceBigboatCompose) ->
    config = (authMechanism, containerShell, authTuples) ->
      image: 'jeroenpeeters/docker-ssh'
      container_name: "#{project}-#{instance}-#{serviceName}-ssh"
      environment:
        CONTAINER: "#{project}-#{instance}-#{serviceName}"
        AUTH_MECHANISM: authMechanism
        HTTP_ENABLED: 'false'
        CONTAINER_SHELL: containerShell
        AUTH_TUPLES: authTuples if authTuples
      labels:
        'bigboat.instance.name': instance
        'bigboat.service.name': serviceName
        'bigboat.service.type': 'ssh'
        'bigboat.container.map_docker': 'true'
      restart: 'unless-stopped'

    if serviceBigboatCompose?.enable_ssh
      config 'noAuth', 'bash'

    else if ssh = serviceBigboatCompose?.ssh
      shell = ssh.shell or 'bash'
      auth = 'noAuth'
      authTuples = null
      if authentication = ssh.authentication
        auth = 'multiUser'
        authTuples = (_.pairs(authentication).map ([key, val]) -> "#{key}:#{val}").join ';'
      config auth, shell, authTuples
