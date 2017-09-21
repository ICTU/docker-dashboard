module.exports = (instances) ->
  names = for instName, inst of instances
    stored = Instances.findOne {name: instName}
    services = (sName for sName of stored.services)
    newInst = lodash.merge {}, stored, inst
    for srv in services
      unless inst.services[srv]
        newInst.services[srv].state = "missing"
        newInst.state = "failing"
    Instances.upsert {name: instName}, newInst
    instName
  updateMissingInstances names

updateMissingInstances = (instNames) ->
  Instances.remove
    name: $nin: instNames
    desiredState: "stopped"

  Instances.find
    name: $nin: instNames
    desiredState: "running"
  .forEach (missingInst) ->
    missingInst.state = "failing"
    for srvName, srv of missingInst.services
      srv.state = "missing"
    Instances.update {name: missingInst.name}, missingInst
