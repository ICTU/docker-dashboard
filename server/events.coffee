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

starting = true
Instances.find().observe
  changed: (newDoc, oldDoc) ->
    if newDoc?.meta?.state == 'active' && oldDoc?.meta.state != 'active'
      newSuccessEvent 'instance', 'started', name: newDoc.name unless starting
    if newDoc?.meta?.state == 'stopping' && oldDoc?.meta.state != 'stopping'
      newInfoEvent 'instance', 'stopping', (name: newDoc.name, user: newDoc.meta.stoppedBy) unless starting
  removed:  (doc) -> newWarningEvent 'instance', 'stopped', name: doc.name unless starting
  added:    (doc) ->
    unless starting
      newInfoEvent 'instance', 'starting', (name: doc.name, user: doc.meta.startedBy)

ApplicationDefs.find().observe
  changed: (doc) ->
    newSuccessEvent 'appdef', 'changed', {name: doc.name, version: doc.version} unless starting
  removed: (doc) ->
    newWarningEvent 'appdef', 'removed', {name: doc.name, version: doc.version} unless starting
  added: (doc) ->
    newSuccessEvent 'appdef', 'added', {name: doc.name, version: doc.version} unless starting

starting = false
