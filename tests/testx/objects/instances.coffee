instancesPanelLocator = (locator) -> (instanceName) ->
  locator: "css"
  value: "div#instancesPanel-#{instanceName} #{locator}"

controlPanel = (instanceName, instanceVersion) ->
  "//tr[@id='controlPanel-#{instanceName}-#{instanceVersion}']"

module.exports =
  # General
  "filterBar":
    locator: "css"
    value: "#searchField"

  "runningInstance": instancesPanelLocator "h4"

  "instances.Running": instancesPanelLocator "h4 span.glyphicon-ok-sign"

  "instances.Stop": instancesPanelLocator "a[title=Stop]"

  "instances.Stop.Yes": instancesPanelLocator "button.stop-instance"

  "instances.StartLog": (instanceName, instanceVersion) ->
    locator: "css"
    value: "tr#controlPanel-#{instanceName}-#{instanceVersion} a[title=Logs]"
