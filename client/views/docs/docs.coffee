Template.docs.onCreated ->
  @docs = new ReactiveVar ''
  Meteor.call 'getDocs', (err, docs) =>
    @docs.set docs

Template.docs.helpers
  docs: -> Template.instance().docs.get()
