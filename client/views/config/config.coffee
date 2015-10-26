Template.config.helpers
  formType: -> if Settings.findOne().isAdmin then 'update' else 'readonly'
