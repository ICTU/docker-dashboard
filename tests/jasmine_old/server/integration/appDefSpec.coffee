Jasmine.onTest ->
  describe 'Application definition', ->

    it 'should be created when invoking the saveApp method', (done) ->
      Meteor.call 'saveApp', 'testApp', 'testVer', 'testApp:testVer', ->
        Meteor.setTimeout ->
          numApps = ApplicationDefs.find({name: 'testApp', version:'testVer'}).count()
          expect(numApps).toEqual 1
          done()
        , 1000

    it 'should be deleted when invoking the deleteApp method', (done) ->
      Meteor.call 'deleteApp', 'testApp', 'testVer', ->
        Meteor.setTimeout ->
          numApps = ApplicationDefs.find({name: 'testApp', version:'testVer'}).count()
          expect(numApps).toEqual 0
          done()
        , 1000
