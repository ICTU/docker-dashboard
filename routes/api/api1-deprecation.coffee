Meteor.startup ->
  if Meteor.isServer

    addDeprecationHeader = ->
      @response.setHeader 'deprecated', 'This API is deprecated in favor of v2. This API endpoint is scheduled for removal.'
      @response.setHeader 'deprecated-since', 'Sun, 20 Nov 2016 00:00:00 GMT'
      @next()

    Router.onBeforeAction addDeprecationHeader, only:
      [
        'apiAdminStartApp',
        'apiAdminStopAllInstances'
        'appdef/crud'
        'apiStartApp'
        'apiStopApp'
        'generate/compose'
        'apiListInstances'
        'apiStatus'
        'apiSystemConfig'
      ]
