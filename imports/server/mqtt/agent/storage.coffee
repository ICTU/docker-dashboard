module.exports = (buckets) ->
  for bucket in buckets
    StorageBuckets.upsert {name: bucket.name}, $set: bucket
  StorageBuckets.remove {name: $nin: _.pluck(buckets, 'name')}
