@StorageBuckets = new Mongo.Collection 'storageBuckets'

StorageBuckets.attachSchema new SimpleSchema
  name:
    type: String
    label: "Bucket name"
