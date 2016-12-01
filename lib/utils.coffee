yaml = require 'js-yaml'

@Utils =
  AppDef:
    toCompose: (ad) ->
      def = yaml.safeLoad ad.def
      bigboatCompose = _.pick def, 'name', 'version', 'description', 'pic'

      for service, val of _.omit def, 'name', 'version', 'description', 'pic'
        bigBoatService = _.pick val, 'enable_ssh', 'endpoint', 'protocol', 'map_docker'
        bigBoatService['map_docker'] = v if v = val.mapDocker
        bigboatCompose[service] = bigBoatService if Object.keys(bigBoatService).length
      ad.bigboatCompose = yaml.safeDump bigboatCompose

      composeDef = _.filter ad.def.split('\n'), (line) ->
        not line.match /(^name|^version|^description|^pic|enable_ssh|endpoint|protocol|mapDocker|map_docker): /
      ad.dockerCompose = (composeDef.join '\n').trim()

      ad
