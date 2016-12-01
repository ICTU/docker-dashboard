dockerCompose = new ReactiveVar null
bigBoatCompose = new ReactiveVar null

Template.editAppDefBox.helpers
  disableOnError: ->
    console.log 'AAAA', dockerCompose.get(), bigBoatCompose.get()
    if dockerCompose.get() and bigBoatCompose.get() then '' else 'disabled'

Template.editAppDefBox.events
  'click #submitButton': (e, tpl) ->
    tpl.$('form').submit()
    tpl.$('.modal').modal('hide')
  'shown.bs.modal .modal': (e, tpl)->
    bigBoatCompose.set null
    bigBoatCompose.set null
  'submit form': (event, tpl) ->
    event.preventDefault()
    console.log dockerCompose.get()
    console.log bigBoatCompose.get()
    if dockerCompose.get() and bigBoatCompose.get()
      if bigBoatCompose.get()?.parsed.name && bigBoatCompose.get()?.parsed.version
        tpl.$("form").trigger $.Event 'save-app-def',
          dockerCompose: dockerCompose.get()
          bigBoatCompose: bigBoatCompose.get()
      else
        throw new Error 'Unable to get the name and/or version from the definition'
    else
      throw new Error 'Cannot parse YAML!'


# Template.editAppDefForm.onRendered ->
#   @autorun =>
#     selectedAppDef = Session.get 'selectedAppDef'
#     @editor = ace.edit @$('.yamlEditor').get(0)
#     @editor.setOptions
#       enableBasicAutocompletion: true
#     @editor.setTheme "ace/theme/chrome"
#     @editor.getSession().setMode "ace/mode/yaml"
#     @editor.getSession().setUseWrapMode(true)
#     handleChange = =>
#       data = @editor.getValue()
#       dockerCompose.set try
#         parsed: jsyaml.load data
#         raw: data
#       catch err
#         console.log 'dockerComposeErr', err
#         line = if err.mark.line == @editor.session.doc.getAllLines().length then err.mark.line - 1 else err.mark.line
#         @editor.getSession().setAnnotations [
#           row: line
#           column: err.mark.column
#           text: err.reason
#           type: 'error'
#         ]
#         false
#       @editor.getSession().setAnnotations [] if dockerCompose.get()
#     @editor.on 'change', handleChange
#     handleChange()


Template.editBigBoatDefForm.onCreated ->
  @autorun =>
    if selectedAppDef = Session.get 'selectedAppDef'
      console.log 'selectedAppDef', selectedAppDef
      Tracker.nonreactive =>
        @editor?.setValue selectedAppDef.bigboatCompose, -1


Template.editBigBoatDefForm.onRendered ->
  @editor = ace.edit @$('.yamlEditor').get(0)
  @editor.setOptions
    enableBasicAutocompletion: true
  @editor.setTheme "ace/theme/chrome"
  @editor.getSession().setMode "ace/mode/yaml"
  @editor.getSession().setUseWrapMode(true)
  @editor.on 'change', =>
    data = @editor.getValue()
    bigBoatCompose.set try
      parsed: jsyaml.load data
      raw: data
    catch err
      console.log 'bigBoatComposeErr', err
      line = if err.mark.line == @editor.session.doc.getAllLines().length then err.mark.line - 1 else err.mark.line
      @editor.getSession().setAnnotations [
        row: line
        column: err.mark.column
        text: err.reason
        type: 'error'
      ]
      false
    @editor.getSession().setAnnotations [] if bigBoatCompose.get()
