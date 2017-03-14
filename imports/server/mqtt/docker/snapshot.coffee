reconciler  = require '../../stateReconciler.coffee'

module.exports =
  containerIds: (ids) -> reconciler.reconcileContainerIdsSnapshot ids
