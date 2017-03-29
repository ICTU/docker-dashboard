appPanel = (appName) ->
  "//div[div[@id='appPanel-#{appName}']]"

appPanelHeading = (appName) ->
  "#{appPanel appName}/div[@class='panel-heading']"

appVersionPanel = (appName, appVersion) ->
  "#{appPanel appName}//tr[th[normalize-space(.)='#{appVersion}']]"

editAppDefFormNamed = (appName, appVersion) ->
  "//div[contains(@id,'editbox') and .//h4[contains(.,'Edit #{appName}:#{appVersion}')]]//div[contains(@class,'appDefEditor')]"

divAppDef = (appName, appVersion) ->
  "//div[@class='modal-content #{appName}:#{appVersion}']"

aceBehaviour = (selector) ->
  get: (val) ->
    browser.executeScript "return ace.edit($('#{selector}').get(0)).getValue();"
  set: (val) ->
    @$('textarea').clear().sendKeys val

module.exports =
  "wholePageApps":
    locator: "xpath"
    value: "//div[@class='apps container']"

  # Edit empty (new) Application Definition form
  "editAppDefForm.Close":
    locator: "xpath"
    value: "//div[contains(@style,'display: block')]//button[.='Close']"
  "editAppDefForm.Save":
    locator: "xpath"
    value: "(//button[.='Save'])[1]"
  "editAppDefForm.DockerComposeEditor":
    locator: "id"
    value: "dockerCompose"
    behaviour: aceBehaviour("#dockerCompose")
  "editAppDefForm.BigboatComposeEditor":
    locator: "id"
    value: "bigboatCompose"
    behaviour: aceBehaviour("#bigboatCompose")

  # Edit existing Application Definition form
  "namedApp.Close": (appName, appVersion) ->
    locator: "xpath"
    value: "#{divAppDef appName, appVersion}//button[.='Close']"
  "namedApp.Save": (appName, appVersion) ->
    locator: "xpath"
    value: "#{divAppDef appName, appVersion}//button[.='Save changes']"
  "namedApp.Content": (appName, appVersion) ->
    locator: "xpath"
    value: "#{divAppDef appName, appVersion}//div[contains(@class,'appDefEditor')]"
    behaviour:
      set: (val) ->
        browser.executeScript "ace.edit('ace-#{appName}:#{appVersion}').getSession().getDocument().setValue('#{val.replace /\n/g, '\\n'}', -1);"
      get: ->
        browser.executeScript "return ace.edit('ace-#{appName}:#{appVersion}').getSession().getDocument().getValue();"

  # Apps list
  "apps.AppPanel": (appName) ->
    locator: "xpath"
    value: "(#{appPanelHeading appName}//a)[1]"
  "apps.Start": (appName, appVersion) ->
    locator: "xpath"
    value: "#{appVersionPanel appName, appVersion}//a[@title='Start']"
  "apps.Start.Name": (appName, appVersion) ->
    locator: "xpath"
    value: "#{appVersionPanel appName, appVersion}//input[@class='form-control instance-name']"
  "apps.Start.Go": (appName, appVersion) ->
    locator: "xpath"
    value: "#{appVersionPanel appName, appVersion}//button[.='Go!']"
  "apps.Remove": (appName, appVersion) ->
    locator: "xpath"
    value: "#{appVersionPanel appName, appVersion}//a[@title='Remove']"
  "apps.Remove.Yes": (appName, appVersion) ->
    locator: "xpath"
    value: "#{appVersionPanel appName, appVersion}//button[.='Yes, destroy it!']"
  "apps.Edit": (appName, appVersion) ->
    locator: "css"
    value: "tr#controlPanel-#{appName}-#{appVersion}"


# ======================================

    "newAppButton":
      locator: "linkText"
      value: "New App"

    "newAppName":
      locator: "css"
      value: "#name"
    "newAppVersion":
      locator: "css"
      value: "#version"

    # Ace editor contents should be injected via behaviour-overriding function
    "newAppCompose":
      locator: "css"
      value: "#composeEditor"
      behaviour:
        set: (val) ->
          browser.executeScript("ace.edit('composeEditor').getSession().setNewLineMode('unix')")
          browser.executeScript("ace.edit('composeEditor').getSession().getDocument().setValue('#{val.replace(/&#10;/g, '\\n')}')")
    # Ace editor contents should be injected via behaviour-overriding function
    "newAppInfra":
      locator: "css"
      value: "#infraEditor"
      behaviour:
        set: (val) -> browser.executeScript("ace.edit('infraEditor').getSession().getDocument().setValue('#{val.replace(/&#10;/g, '\\n')}')")
