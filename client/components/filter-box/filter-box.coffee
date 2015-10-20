Template.filterBox.helpers
  searchTerms: -> Session.get(Template.instance().data.sessionVar)

Template.filterBox.events
  'input #searchField': (e, t) -> Session.set t.data.sessionVar, e.target.value
  'click .clear-filter': (e, t) ->  Session.set t.data.sessionVar, null
