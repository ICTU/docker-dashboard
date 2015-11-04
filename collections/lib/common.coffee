Mongo.Collection::updateCollection = (leaves) ->
  @remove key: {$nin: _.pluck(leaves, 'key')}
  leaves?.map (leaf) =>
    obj = (@findOne key: leaf.key) or {}
    obj = _.extend _.omit(obj, '_id'), leaf
    @upsert {key: leaf.key}, obj
