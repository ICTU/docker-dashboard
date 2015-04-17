robochick =
  "ICTU Cloud Terminal ~ Powered by RoboChick\n\n
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;___//\n
&nbsp;&nbsp;&nbsp;&nbsp;/.__.\\\n
&nbsp;&nbsp;&nbsp;&nbsp;\\ \\/ /\n
&nbsp;'__/    \\\n
&nbsp;&nbsp;\\-      )\n
&nbsp;&nbsp;&nbsp;\\_____/\n
_____|_|____\n
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\" \""

Template.terminal.onRendered ->
  instance = @data.instance
  console.log instance
  service = instance.services[@data.serviceName]
  connectionId = null
  prompt = null
  setPrompt = null

  window.document.title = "RoboChick ~ #{service.hostname}"
  $('html').css 'cssText', 'height:100% !important;'
  $('body').css 'cssText', 'height:100% !important; background:none !important; background-color: #000 !important;'

  evt = new EventSource "/api/v1/stream/#{service.dockerContainerName}"
  evt.addEventListener 'connectionId', (event) =>
    connectionId = event.data
    @$('#terminal').terminal().echo "Connection established to #{service.hostname}"
  evt.addEventListener 'data', (event) =>
    @$('#terminal').terminal().echo EJSON.parse(event.data).data
  evt.addEventListener 'prompt', (event) ->
    console.log 'prompt', event.data
    prompt = EJSON.parse(event.data).data
    setPrompt prompt
  evaluator = (command, term) ->
    console.log (EJSON.stringify cmd: command)
    term.echo "#{prompt}#{command}"
    HTTP.post "/api/v1/stream/#{connectionId}/send", (data: cmd: command), (err, response) ->
      term.error err if err
    undefined
  @$('#terminal').terminal evaluator, prompt: ((x)-> setPrompt = x), greetings: robochick, exit: false
