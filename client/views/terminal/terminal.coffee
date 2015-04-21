robochick =
  "\r\n\r\nICTU Cloud Terminal ~ Powered by RoboChick\r\n\r\n
\x1b[5C___//\r\n
\x1b[4C/.__.\\\r\n
\x1b[4C\\ \\/ /\r\n
\x1b[1C'__/    \\\r\n
\x1b[2C\\-      )\r\n
\x1b[3C\\_____/\r\n
_____|_|____\r\n
\x1b[5C\" \""

Template.terminal.onRendered ->

  connectionId = null
  instance = @data.instance
  service = instance.services[@data.serviceName]
  term = new Terminal
    cols: 80
    rows: 24
    useStyle: true
    screenKeys: true
    cursorBlink: true

  window.document.title = "RoboChick ~ #{service.hostname}"
  $('html').css 'cssText', 'height:100% !important;'
  $('body').css 'cssText', 'height:100% !important; background:none !important; background-color: #000 !important; padding: 0 10px 0 10px !important;'

  evt = new EventSource "/api/v1/terminal/stream/#{@data.instanceName}/#{@data.serviceName}"
  evt.addEventListener 'connectionId', (event) ->
    connectionId = event.data
    term.write "Connection established to #{service.hostname}\r\n"
  evt.addEventListener 'data', (event) ->
    term.write EJSON.parse(event.data).data
  evt.addEventListener 'exit', ->
    evt.close()
    term.write "\r\nTerminal exited"

  term.on 'data', (data) ->
    if evt.readyState == EventSource.OPEN
      HTTP.post "/api/v1/terminal/send/#{connectionId}", (data: cmd: data), (err, response) ->
        term.error err if err

  term.on 'title', (title) ->
    document.title = title

  term.open document.body
  term.write "\x1b[31m#{robochick}\x1b[m\r\n"

  window.onresize = (event) ->
    clearTimeout @id
    @id = setTimeout doneResizing, 500

  doneResizing = ->
    rows = Math.round $(window).height()/15
    cols = Math.round $(window).width()/7.5
    console.log $(window).height(), $(window).width()
    console.log rows, cols
    HTTP.post "/api/v1/terminal/resize-window/#{connectionId}", (data: {cols: cols, rows: rows}), (err, response) ->
      term.error err if err
      term.resize cols, rows
