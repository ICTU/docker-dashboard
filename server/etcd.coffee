Etcd = Npm.require 'node-etcd'

etcd = (endpoint) ->
  parsedEndpoint = endpoint.match /^(.*):\/\/([A-Za-z0-9\-\.]+):([0-9]+)?(.*)$/
  [all, protocol, host, port, uri] = parsedEndpoint

  client = new Etcd "#{host}","#{port}"

  get: (key, cb) -> client.get "#{key}", cb

  set: (key, value) -> client.set "#{key}", value

  wait: (key, cb) -> client.watch "#{key}", cb

  delete: (key, cb) -> client.del "#{key}", cb

  discover: (key, cb) ->
    @get "#{key}", (error, result) ->
      if error or not result?.node
        console.error "Error while trying to get data ->"
        console.error error
        cb error, null
      else
        objects = []
        discover_ = (node) ->
          node?.nodes?.map (n) =>
            if n.value
              objects.push n
            else if n
              discover_ n
        if result?.node
          discover_(result.node)
          cb null, objects
        else cb "ETCD: Unexpected result format #{EJSON.stringify result, null, 4}", null

@EtcdClient =
  set: (key, value) ->
    etcd(Settings.get('etcd')).set key, value
  wait: (key, cb) ->
    etcd(Settings.get('etcd')).wait key, Meteor.bindEnvironment(cb)
  delete: (key, cb) ->
    etcd(Settings.get('etcd')).delete key, Meteor.bindEnvironment(cb)
  discover: (key, cb) ->
    etcd(Settings.get('etcd')).discover key, Meteor.bindEnvironment(cb)
