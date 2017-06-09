reconciler  = require '../../stateReconciler.coffee'

module.exports = (data) ->
  startCheckStatus = {
    succeeded: data.success
  }
  reconciler.updateStartCheckStatus startCheckStatus, data.service.labels
  console.log 'START_CHECK', data
