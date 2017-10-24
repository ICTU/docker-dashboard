{ Meteor }          = require 'meteor/meteor'
{ createContainer } = require 'meteor/react-meteor-data'
React               = require 'react'
Helpers             = require '../../helpers.coffee'
StorageBucketList   = require '../storage/bucketList.cjsx'
pretty              = require 'prettysize'


module.exports = createContainer (props) ->
  instances = Instances?.find({}, {fields: {name: 1, 'storageBucket': 1}}).fetch()
  usage = {}
  for instance in instances when instance.storageBucket
    usage[instance.storageBucket] ?= []
    usage[instance.storageBucket].push instance.name
  buckets: StorageBuckets?.find({name: {$regex: props.filter or '', $options: 'i'}}, sort: name: 1).map (bucket) ->
    _.extend bucket,
      size: pretty bucket.size
      usedBy: usage[bucket.name]
  onDelete: -> Meteor.call 'storage/buckets/delete', @name
  onCopy: (source, dest) ->  Meteor.call 'storage/buckets/copy', source, dest
  authenticated: Helpers.isAuthenticated()
, StorageBucketList
