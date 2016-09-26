updateStorageBuckets = ->
  for bucket in (buckets = Agent.listStorageBuckets())
    StorageBuckets.upsert {name: bucket.name}, $set: bucket
  StorageBuckets.remove {name: $nin: _.pluck(buckets, 'name')}


Meteor.setInterval updateStorageBuckets, 1000
