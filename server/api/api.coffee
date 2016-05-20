@API =
  authentication: (apiKey) ->
    getUser = APIKeys.findOne({ 'key': apiKey }, fields: 'owner': 1)
    if getUser then getUser.owner else false
  connection: (request) ->
    request[content] = API.utility.getRequestContents(request)
    apiKey = request.api_key
    validUser = API.authentication(apiKey)
    if validUser
      delete request.api_key
      return request
    else
      return { error: 401, message: 'Invalid API key.' }
  handleAuthRequest: (context, f, args, successResponse, failedResponse) ->
    context.request = API.connection(context.request)
    if !context.request.content.error
      API.handleRequest(context, f, args, successResponse, failedResponse)
    else
      API.utility.response context, 401, { error: 401, message: 'Invalid API key.' }
  handleRequest: (context, f, args, successResponse, failedResponse) ->
    console.log context.request
    console.log "Received '#{JSON.stringify context.method}' -> #{JSON.stringify context.request}"
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
      f.apply @, args
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
