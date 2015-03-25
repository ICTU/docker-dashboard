Template['base-layout'].helpers
  isAdminBoard: -> Meteor.settings.public.admin

Template['base-layout'].events
  'change #projectName': (e, t) ->
    Meteor.call 'setting', 'project', e.target.value
