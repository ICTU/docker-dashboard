parsed = new ReactiveVar null

Template.viewAppDefBox.helpers
  hash: -> CryptoJS.MD5 "#{@name}#{@version}"

Template.viewAppDefForm.onRendered ->
  @editor = ace.edit @.$('.appDefEditor').get(0)
  @editor.setOptions
    readOnly: true
    highlightActiveLine: false
    highlightGutterLine: false
  @editor.setTheme "ace/theme/xcode"
  @editor.getSession().setMode "ace/mode/yaml"
  @editor.getSession().setUseWrapMode(true)
