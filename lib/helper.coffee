packageJson = require '/package.json'
yaml = require 'js-yaml'


@Helper =
  extractTags: (appDef) ->
    try
      def = yaml.safeLoad appDef
      return def.tags if def?.tags
    catch error
      console.log error
    []
  appVersion: -> packageJson.version
