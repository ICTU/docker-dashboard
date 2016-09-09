updateStorageBuckets = ->
  for appName in (buckets = Agent.listStorageBuckets())
    StorageBuckets.upsert {name: appName}, {$set: name: appName}
  StorageBuckets.remove {name: $nin: buckets}


Meteor.setInterval updateStorageBuckets, 1000
