Template.status.helpers
  lastCheckHuman: -> moment(@lastCheck).fromNow()
  statusColor: -> if @isUp then 'green' else 'red'
