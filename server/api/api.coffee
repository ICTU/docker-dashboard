@API =
  authentication: (apiKey) ->
    authenticateUser(apiKey) || authenticateDeployKey(apiKey)
  authenticateUser: (apiKey) ->
    getUser = APIKeys.findOne({ 'key': apiKey }, fields: 'owner': 1)
    if getUser then getUser.owner else false
  authenticateDeployKey: (apiKey) ->
    apiKey in getDeployKeys()
  connection: (request) ->
    request.content = API.utility.getRequestContents(request)
    apiKey = request.content.api_key
    validUser = API.authentication(apiKey)
    if validUser
      delete request.content.api_key
    else
      request.content.error = { error: 401, message: 'Invalid API key.' }
    request
  handleAuthRequest: (context, f, args, successResponse, failedResponse) ->
    context.request = API.connection(context.request)
    if !context.request.content.error
      API.handleRequest(context, f, args, successResponse, failedResponse)
    else
      API.utility.response context, 401, context.request.content.error
  handleRequest: (context, f, args, successResponse, failedResponse) ->
    context.request.content = API.utility.getRequestContents(context.request) unless context.request.content
    console.log "Received '#{context.method}' -> #{JSON.stringify context.request.content}"
    try
      API.methods[context.method] context, f, args, successResponse
    catch ex
      failedResponse.description = ex.message
      API.utility.response context, failedResponse.statusCode, failedResponse
  methods:
    GET: (context, f, args, successResponse) ->
      API.utility.execute context, f, args, successResponse
    POST: (context, f, args, successResponse) ->
      API.utility.execute context, f, args, successResponse
    PUT: (context, f, args, successResponse) ->
      API.utility.execute context, f, args, successResponse
    DELETE: (context, f, args, successResponse) ->
      API.utility.execute context, f, args, successResponse

  utility:
    execute: (context, f, args, successResponse) ->
      f.apply @, args if f
      API.utility.response context, 200, successResponse
    getRequestContents: (request) ->
      switch request.method
        when 'GET'
          return request.query
        when 'POST', 'PUT', 'DELETE'
          return request.body
    response: (context, statusCode, data) ->
      context.response.setHeader 'Content-Type', 'application/json'
      context.response.statusCode = statusCode
      context.response.end JSON.stringify(data)
    validate: (data, pattern) ->
      Match.test data, pattern
