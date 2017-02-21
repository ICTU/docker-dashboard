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

    if (ssh = serviceBigboatCompose?.ssh) and (typeof ssh is 'object')
      shell = ssh.shell or 'bash'
      auth = 'noAuth'
      authTuples = null
      if users = ssh.users
        auth = 'multiUser'
        authTuples = (_.pairs(users).map ([key, val]) -> "#{key}:#{val}").join ';'
      config auth, shell, authTuples
    else if serviceBigboatCompose?.enable_ssh or serviceBigboatCompose?.ssh is true
        config 'noAuth', 'bash'
