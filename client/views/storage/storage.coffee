Storage = require '/imports/ui/meteor/storage.cjsx'

Template.storage.helpers
  Storage: -> Storage
  nameFilter: -> Session.get 'queryName'

Template.storage.events
  'submit #create-bucket-form': (e, tpl) ->
    e.preventDefault()
    console.log tpl.$('.bucket-name').val()
    Meteor.call 'storage/buckets/create', tpl.$('.bucket-name').val()
