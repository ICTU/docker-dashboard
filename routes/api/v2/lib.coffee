
module.exports =
  isInfraTagAndNotAdmin: (instanceName, key) ->
    instance = Instances.findOne {name: instanceName}
    apiKey = APIKeys.findOne key: key
    user = Meteor.users.findOne(apiKey.owner)
    instance.app.parameters?.tags?.includes('infra') and not ('admin' in (user.roles?.__global_roles__ or []))
    
  endWithHttpCode: endWithHttpCode = (response, code) ->
    response.writeHead code
    response.end()

  notFound: (response) ->
    endWithHttpCode response, 404

  foundJson: (response, code, doc) ->
    response.setHeader 'content-type', 'application/json'
    response.writeHead code
    response.end EJSON.stringify doc

  endWithError: (response, code, errorMessage) ->
    response.setHeader 'content-type', 'application/json'
    response.writeHead code
    response.end EJSON.stringify message: errorMessage

  foundYaml: (response, code, doc) ->
    response.setHeader 'content-type', 'text/yaml'
    response.writeHead code
    response.end doc
