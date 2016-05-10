newEvent = (type, subject, action, info) ->
  Events.insert
    type: type
    subject: subject
    action: action
    info: info
    timestamp: new Date()

newSuccessEvent = (subject, action, info) -> newEvent 'success', subject, action, info
newWarningEvent = (subject, action, info) -> newEvent 'warning', subject, action, info
newInfoEvent    = (subject, action, info) -> newEvent 'info', subject, action, info

Instances.find().observe
  changed: (newDoc, oldDoc) ->
    if newDoc?.meta?.state == 'active' && oldDoc?.meta.state != 'active'
      newSuccessEvent 'instance', 'started', name: newDoc.name
    if newDoc?.meta?.state == 'stopping' && oldDoc?.meta.state != 'stopping'
      newWarningEvent 'instance', 'stopping', name: newDoc.name
  removed:  (doc) -> newWarningEvent 'instance', 'stopped', name: doc.name
  added:    (doc) -> newInfoEvent 'instance', 'starting', name: doc.name

ApplicationDefs.find().observe
  changed: (doc) ->
    newSuccessEvent 'appdef', 'changed', {name: doc.name, version: doc.version}
  removed: (doc) ->
    newWarningEvent 'appdef', 'removed', {name: doc.name, version: doc.version}
  added: (doc) ->
    newInfoEvent 'appdef', 'added', {name: doc.name, version: doc.version}
