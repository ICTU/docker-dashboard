Meteor.startup ->
  etcd = (endpoint) ->
    endpoint = endpoint[...-1] if endpoint[-1..] is "/" # remove the trailing / if there is one

    get: (key) ->
      HTTP.get "#{endpoint}/#{key}"

    get: (key, callback) ->
      HTTP.get "#{endpoint}/#{key}", callback

    set: (key, value) ->
      HTTP.put "#{endpoint}/#{key}",
        params:
          value: value

    delete: (key) -> HTTP.del "#{endpoint}/#{key}"

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
          discover_(result.data.node)
          cb null, objects

  @EtcdClient =
    delete: (key) ->
      etcd(Settings.findOne().etcd).discover key
    discover: (key, cb) ->
      etcd(Settings.findOne().etcd).discover key, cb
