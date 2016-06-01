Template.apiSettings.onCreated ->
  @subscribe "APIKey"

Template.apiSettings.onRendered ->
  $(document).ready ->
    $('#btnCopyApi').tooltip()
    $('#btnRegenerateApi').tooltip()

    $('#btnCopyApi').bind 'click', ->
      new Clipboard('#btnCopyApi')
      $('#btnCopyApi').trigger('copied', ['Copied!'])

    $('#btnCopyApi').bind 'copied', (event, message) ->
      $(this).attr('title', message)
          .tooltip('fixTitle')
          .tooltip('show')
          .attr('title', "Copy to Clipboard")
          .tooltip('fixTitle')

Template.apiSettings.helpers
  apiKey: -> APIKeys.findOne()?.key

Template.apiSettings.events
  'click #btnRegenerateApi': (e) ->
    e.stopPropagation()
    userId = Meteor.userId()

    BootstrapModalPrompt.prompt
      title: "Generate new key"
      content: "Are you sure? This will invalidate your current key!"
      btnDismissText: "No"
      btnOkText: "Yes"
    , (confirmRegeneration) ->
      if confirmRegeneration
        Meteor.call "regenerateApiKey", userId, (err, res) ->
          console.error "Failed to regenerate key: #{err.reason}" if err
