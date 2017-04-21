prettysize = require('prettysize')

module.exports =
  memory: (mem) ->
    name = 'Memory'
    fivehundredmb = 500000000
    Services.upsert {name: name}, {
      name: name,
      lastCheck: new Date(),
      isUp: mem.free > fivehundredmb,
      description: "Total size: #{prettysize(mem.total)}. <strong>Available: #{prettysize(mem.free)}</strong>"
    }
  cpu: (info) ->
    name = 'System Load'
    f = (n) -> parseFloat(n).toFixed 2
    Services.upsert {name: name}, {
      name: name,
      lastCheck: new Date(),
      isUp: info.loadavg['5min'] < info.cpus.count and info.loadavg['1min'] < (info.cpus.count * 1.5),
      description: """The system has #{info.cpus.count} CPUs. CPU type: #{info.cpus.model}<br/><strong>Load average:</strong>
      1 minute: #{f info.loadavg['1min']}, 5 minutes: #{f info.loadavg['5min']}, 15 minutes: #{f info.loadavg['15min']}"""
    }
  uptime: (uptime) ->
    name = 'System Uptime'
    Services.upsert {name: name}, {
      name: name,
      lastCheck: new Date(),
      isUp: true,
      description: "#{moment.duration(uptime, 'seconds').humanize()}"
    }
