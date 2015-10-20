parsed = new ReactiveVar null

Template.editAppDefBox.helpers
  hash: -> CryptoJS.MD5 "#{@name}#{@version}"
  disableOnError: -> if parsed.get() then '' else 'disabled'

Template.editAppDefBox.events
  'click #submitButton': (e, tpl) ->
    tpl.$('form').submit()
    tpl.$('.modal').modal('hide')
  'shown.bs.modal .modal': -> parsed.set null

Template.editAppDefForm.onRendered ->
  @editor = ace.edit @.$('.appDefEditor').get(0)
  @editor.setOptions
    enableBasicAutocompletion: true
  @editor.setTheme "ace/theme/chrome"
  @editor.getSession().setMode "ace/mode/yaml"
  @editor.getSession().setUseWrapMode(true)
  @editor.on 'change', =>
    data = @editor.getValue()
    parsed.set try
      jsyaml.load data
    catch err
      line = if err.mark.line == @editor.session.doc.getAllLines().length then err.mark.line - 1 else err.mark.line
      @editor.getSession().setAnnotations [
        row: line
        column: err.mark.column
        text: err.reason
        type: 'error'
      ]
      false
    @editor.getSession().setAnnotations [] if parsed.get()

Template.editAppDefForm.events
  'submit form': (event, tpl) ->
    event.preventDefault()
    data = tpl.editor.getValue()
    if parsed.get()
      if parsed.get()?.name && parsed.get()?.version
        tpl.$("form").trigger $.Event 'save-app-def',
          yaml:
            parsed: parsed.get()
            raw: data
      else
        throw new Error 'Unable to get the name and/or version from the definition'
    else
      throw new Error 'Cannot parse YAML!'
