describe 'Application definition', ->

  beforeEach (done) ->
    TH.expectTextToEqual 'a[href="/apps"]', 'Applications'
    TH.clickLink '/apps'
    done()

  it 'can be created using the frontend', (done) ->
    TH.expectTextToEqual 'a[href="/apps/create"]', 'Create'
    TH.clickLink '/apps/create'
    TH.defer ->
      TH.triggerInput '#appDef', 'nameOfApp:versionOfApp'
      TH.expectValueToEqual '#appName', 'nameOfApp'
      TH.expectValueToEqual '#appVersion', 'versionOfApp'
      TH.clickButton 'type=submit'
      TH.deferLong done

  it 'can be deleted using the frontend', (done) ->
    TH.defer ->
      TH.expectNumElementsToEqual 'a[href="/apps/edit/nameOfApp/versionOfApp"]', 1
      TH.clickLink '/apps/edit/nameOfApp/versionOfApp'
      TH.defer ->
        TH.clickButton 'id=delete'
        TH.deferLong ->
          TH.expectNumElementsToEqual 'a[href="/apps/edit/nameOfApp/versionOfApp"]', 0
          done()
