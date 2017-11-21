Meteor.startup ->
  Jobs  = JobCollection 'jobs'
  Jobs.remove {}

  jobs = []

  for agent in Settings.get('agentUrl')
    jobs.push
      name: "Agent #{agent}"
      url: "#{agent}/version"

  for j in jobs
    job = new Job Jobs, 'serviceCheck', j
    job.repeat
      repeats: Jobs.forever
      wait: 1000 * 20
    job.retry
      wait: 1000 * 10
    job.save()

  Jobs.processJobs 'serviceCheck', (job, callback) ->
    HTTP.get job.data.url, (err, data) ->
      if err or not data
        Services.upsert {name: job.data.name},
          name: job.data.name
          lastCheck: new Date()
          description: '<strong>The agent is offline.</strong>'
          isUp: false

        job.fail err.content
      else
        resp = JSON.parse data.content
        Services.upsert {name: job.data.name},
          name: job.data.name
          lastCheck: new Date()
          description: "Agent version: <strong>#{resp.version}</strong>"
          isUp: true
          details: resp
        job.done()
    callback()


  Jobs.startJobServer()
