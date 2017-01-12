packageJson = require '/package.json'
yaml = require 'js-yaml'


@Helper =
  extractTags: (appDef) ->
    tags = []
    try
      def = yaml.safeLoad appDef
      if def?.tags
        tags =
          if typeof def.tags is "object"
            if Array.isArray def.tags
              def.tags
            else
              ["#{key}: #{JSON.stringify val}" for key, val of def.tags]
          else [def.tags]
    catch error
      console.error error
    tags
  appVersion: -> packageJson.version
