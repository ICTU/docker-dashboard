Storage = require '/imports/ui/meteor/storage.cjsx'

Template.storage.helpers
  Storage: -> Storage
  nameFilter: -> Session.get 'queryName'

Template.storage.events
  'click .new-bucket-toggle': (e, tpl) ->
    tpl.$('#new-bucket-form').toggleClass('open')
  'submit #create-bucket-form': (e, tpl) ->
    e.preventDefault()
    unless tpl.$('#create-bucket-form :invalid').length
      Meteor.call 'storage/buckets/create', tpl.$('.bucket-name').val()
      tpl.$('#new-bucket-form').removeClass('open')
