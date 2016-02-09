Meteor.startup ->
  Etcd2 = Meteor.npmRequire 'node-etcd'
  etcd2 = new Etcd2 'etcd1.isd.ictu','4001'

  etcd = (endpoint) ->
    endpoint = endpoint[...-1] if endpoint[-1..] is "/" # remove the trailing / if there is one

    get: (key, callback) ->
      etcd2.get "#{key}", callback

    set: (key, value) ->
      etcd2.set "#{key}", value

    wait: (key, cb) ->
      etcd2.watch key, cb

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
          if result?.node
            discover_(result.node)
            cb null, objects
          else cb "ETCD: Unexpected result format #{EJSON.stringify result, null, 4}", null

  @EtcdClient =
    set: (key, value) ->
      etcd(Settings.findOne().etcd).set key, value
    wait: (key, cb) ->
      etcd(Settings.findOne().etcd).wait key, Meteor.bindEnvironment(cb)
    delete: (key, cb) ->
      etcd(Settings.findOne().etcd).delete key, Meteor.bindEnvironment(cb)
    discover: (key, cb) ->
      etcd(Settings.findOne().etcd).discover key, Meteor.bindEnvironment(cb)
