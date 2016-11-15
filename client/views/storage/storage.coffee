Storage = require '/imports/ui/meteor/storage.cjsx'
pretty = require 'prettysize'

Template.storage.helpers
  Storage: -> Storage
  nameFilter: -> Session.get 'queryName'
  datastore: -> Datastores?.findOne()
  storageBuckets: -> StorageBuckets?.find {}, sort: name: 1
  prettyValue: (value) -> pretty(value)
  storageUsageClass: ->
    ratio = parseInt(Datastores?.findOne().percentage[..-1])
    switch
      when ratio > 95 then 'progress-bar-danger'
      when ratio > 80 then 'progress-bar-warning'
      else ''
Template.storage.events
  'submit #create-bucket-form': (e, tpl) ->
    e.preventDefault()
    Meteor.call 'storage/buckets/create', tpl.$('#bucket-name').val(), ->
      tpl.$('#bucket-name').val ''
  'click button.size-buckets': (e, tpl) ->
    buckets = StorageBuckets?.find {}, sort: name: 1
    buckets.forEach (bucket) ->
      Meteor.call 'storage/buckets/size', bucket._id
