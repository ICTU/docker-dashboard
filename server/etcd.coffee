Meteor.startup ->
  etcd = (endpoint) ->
    endpoint = endpoint[...-1] if endpoint[-1..] is "/" # remove the trailing / if there is one

    get: (key, callback) ->
      HTTP.get "#{endpoint}/#{key}", callback

    set: (key, value) ->
      HTTP.put "#{endpoint}/#{key}",
        params:
          value: value

    wait: (key, cb) -> @discover "#{key}&wait=true", cb

    delete: (key) -> HTTP.del "#{endpoint}/#{key}"

    discover: (key, cb) ->
      @get "#{key}", (error, result) ->
        if error
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
          else cb error, null

  @EtcdClient =
    wait: (key, cb) ->
      etcd(Settings.findOne().etcd).wait key, cb
    delete: (key) ->
      etcd(Settings.findOne().etcd).delete key
    discover: (key, cb) ->
      etcd(Settings.findOne().etcd).discover key, cb
