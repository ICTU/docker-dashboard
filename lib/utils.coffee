yaml = require 'js-yaml'

@Utils =
  AppDef:
    toCompose: (ad) ->
      migrateVolume = (serviceName, volume) ->
        vol = volume = volume.replace /(:do_not_persist)|(:shared)/, ''
        hasRo = (vol = vol.replace /:ro/, '') isnt volume
        hasRw = (vol = vol.replace /:rw/, '') isnt volume
        splitted = vol.split ':'
        newVolume = if splitted.length is 2
          "/#{serviceName}#{splitted[0]}:#{splitted[1]}"
        else
          "/#{serviceName}#{vol}:#{vol}"

        if hasRo then "#{newVolume}:ro"
        else if hasRw then "#{newVolume}:rw"
        else newVolume

      partitionVolumes = (content) ->
        regex = /(?:volumes: *\s)((?: *- {1,}\/.+\s?)*)/gm
        if m = regex.exec content
          m[1].split('\n').map((i) -> i.replace /^\s*\-/, '').map((i) -> i.trim()).filter((i) -> i.length)
        else []

      partitionByService = (content) ->
        serviceRegex = /^(?:(.+?):|(?:.+))\s(?:(?!^\w)(?:.*?)\s?)+/gm
        while match = serviceRegex.exec content
          console.log 'byService', match
          data: match[0]
          name: match[1]

      collectTags = (content) ->
        if match = /#\s?tags:\s?(.+)/.exec content
          match[1].split ' '

      stripOldDirectives = (content) ->
        composeDef = _.filter content.split('\n'), (line) ->
          not line.match /(^name|^version|^description|^pic|enable_ssh|endpoint|protocol|mapDocker|map_docker|tags): /
        (composeDef.join '\n').trim()

      partitionByVolume = (content) ->
        regex = /([^]+)?(volumes: *\n(?: *- {1,}\/.+\s?)*)([^]+)?/
        if match = regex.exec content
          match
        else []

      migrateVolumes = (content) ->
        services = partitionByService content
        (services.map (s) ->
          data = s.data
          partitions = partitionByVolume data
          console.log 'partitions', partitions
          if partitions.length
            [all, pre, volumes, post] = partitions
            console.log '!pre', pre
            console.log '!volumes', volumes
            console.log '!post', post
            console.log '!name', s.name
            console.log '~volumes', partitionVolumes(volumes)
            if s.name then partitionVolumes(volumes).forEach (vol) ->
              volumes = volumes.replace vol, (migrateVolume s.name, vol)
            data = "#{pre or ''}#{volumes or ''}#{post or ''}"
            console.log 'aaaa!', data
          data
        ).join '\n'

      createBigBoatCompose = (content) ->
        def = yaml.safeLoad content
        bigboatCompose = _.pick def, 'name', 'version', 'description', 'pic'

        for service, val of _.omit def, 'name', 'version', 'description', 'pic'
          bigBoatService = _.pick val, 'enable_ssh', 'endpoint', 'protocol', 'map_docker'
          bigBoatService['map_docker'] = v if v = val.mapDocker
          bigboatCompose[service] = bigBoatService if Object.keys(bigBoatService).length

        if match = /#\s?tags:\s?(.+)/.exec content
          bigboatCompose.tags = match[1].split ' '
        "#{yaml.safeDump bigboatCompose, {noRefs: true, noCompatMode: true}}"

      ad.dockerCompose = migrateVolumes stripOldDirectives ad.def
      ad.bigboatCompose = createBigBoatCompose ad.def
      ad
