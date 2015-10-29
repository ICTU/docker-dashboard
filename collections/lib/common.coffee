Mongo.Collection::etcdSync = (baseKey, transformer) ->
  try
    Etcd.discover baseKey, transformer, (err, nodes) =>
      @updateCollection.call @, nodes
  catch
    console.log "Error while trying to read #{baseKey}!"

Mongo.Collection::updateCollection = (leaves) ->
  @remove key: {$nin: _.pluck(leaves, 'key')}
  leaves?.map (leaf) =>
    obj = (@findOne key: leaf.key) or {}
    obj = _.extend _.omit(obj, '_id'), leaf
    @upsert {key: leaf.key}, obj
