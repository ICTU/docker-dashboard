Meteor.startup ->
  Jobs  = JobCollection 'jobs'
  Jobs.remove {}

  job = new Job Jobs, 'serviceCheck',
    name: 'ETCD'
    url: Settings.etcd()
  job.repeat
    repeats: Jobs.forever
    wait: 1000 * 60
  job.retry
    wait: 1000 * 60
  job.save()

  Jobs.processJobs 'serviceCheck', (job, callback) ->
    HTTP.get job.data.url, (err, data) ->
      if err or not data
        Services.upsert {name: job.data.name},
          name: job.data.name
          lastCheck: new Date()
          isUp: false

        job.fail err.content
      else
        Services.upsert {name: job.data.name},
          name: job.data.name
          lastCheck: new Date()
          isUp: true
        job.done()
    callback()


  Jobs.startJobs()
