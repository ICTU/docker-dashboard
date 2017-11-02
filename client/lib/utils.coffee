HTTPS_PORTS = ['443', '8443']
HTTP_PORTS = ['80', '4567', '8000', '8080', '8081', '8181', '8668', '9000']

@findWebPort = (service) ->
  p = 80
  service?.ports?.forEach (port) ->
    port = port.split('/')[0]
    if port in HTTPS_PORTS.concat(HTTP_PORTS) then p = port
  p

@determineProtocol = (port) ->
  if port in HTTPS_PORTS
    "https"
  else
    "http"
