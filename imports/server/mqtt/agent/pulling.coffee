reconciler  = require '../../stateReconciler.coffee'


module.exports = (msg) ->
  reconciler.imagePulling "#{msg.image}:#{msg.version}", msg.instance
