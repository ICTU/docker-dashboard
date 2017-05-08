reconciler  = require '../../stateReconciler.coffee'

module.exports =
  info: (info) ->
    availableIps = info.totalIps - info.usedIps
    Services.upsert {name: 'Available IPs'}, {
      name: 'Available IPs',
      lastCheck: new Date(),
      isUp: availableIps > 20,
      description: "Total number of IPs: #{info.totalIps}. IPs in use: #{info.usedIps}. <strong>Available IPs: #{availableIps}</strong>"
      details: info
    }
