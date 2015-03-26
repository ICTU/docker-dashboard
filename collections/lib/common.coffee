Mongo.Collection::etcdSync = (baseKey, transformer) ->
  try
    Etcd.discover baseKey, transformer, (err, nodes) =>
      @updateCollection.call @, nodes
  catch
    console.log "Error while trying to read #{baseKey}!"

Mongo.Collection::updateCollection = (leaves) ->
  @remove key: {$nin: _.pluck(leaves, 'key')}
  leaves?.map (leaf) =>
    @upsert key: leaf.key, leaf
