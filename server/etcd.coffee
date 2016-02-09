Meteor.startup ->
  etcd = (endpoint) ->
    endpoint = endpoint[...-1] if endpoint[-1..] is "/" # remove the trailing / if there is one

    get: (key, callback) ->
      HTTP.get "#{endpoint}/#{key}", callback

    set: (key, value) ->
      HTTP.put "#{endpoint}/#{key}",
        params:
          value: value

    wait: (key, cb) -> @get "#{key}&wait=true", cb

    delete: (key, cb) -> HTTP.del "#{endpoint}/#{key}", cb

    discover: (key, cb) ->
      @get "#{key}", (error, result) ->
        if error or not result?.data?.node
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
          if result?.data?.node
            discover_(result.data.node)
            cb null, objects
          else cb "ETCD: Unexpected result format #{EJSON.stringify result, null, 4}", null

  @EtcdClient =
    set: (key, value) ->
      etcd(Settings.findOne().etcd).set key, value
    wait: (key, cb) ->
      etcd(Settings.findOne().etcd).wait key, cb
    delete: (key, cb) ->
      etcd(Settings.findOne().etcd).delete key, cb
    discover: (key, cb) ->
      etcd(Settings.findOne().etcd).discover key, cb
