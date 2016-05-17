Template.config.helpers
  formType: -> if Settings.get('isAdmin') then 'update' else 'readonly'
