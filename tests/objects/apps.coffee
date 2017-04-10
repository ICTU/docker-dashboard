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
    browser.executeScript "return ace.edit($('#{selector}')[0]).getValue();"
  set: (val) ->
    v = val.replace /\n/g, '\\n'
    script = "return ace.edit(jQuery('#{selector}')[0]).setValue('#{v}');"
    browser.executeScript script

module.exports =
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
