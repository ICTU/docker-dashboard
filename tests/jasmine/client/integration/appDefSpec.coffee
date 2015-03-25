describe 'Application deffinition', ->
  beforeEach (done) ->
    expect($('a[href="/apps"]').text().trim()).toEqual('Applications')
    $('a[href="/apps"]').click()
    done()

  it 'is displayed when created via the method', (done) ->
    Meteor.call 'saveApp', 'testApp', 'testVer', 'testApp:testVer', ->
      setTimeout ->
        expect($('a[href="/apps/edit/testApp/testVer"]').text()).toEqual('testVer')
        done()
      , 1000
  
  it 'is removed from the list when deleted via the method', (done) ->
    Meteor.call 'deleteApp', 'testApp', 'testVer', ->
      setTimeout ->
        expect($('a[href="/apps/edit/testApp/testVer"]').text()).toEqual('')
        done()
      , 1000
