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

  "toggleInstance": instancesPanelLocator "h4 a.toggle"

  "instances.Running": instancesPanelLocator "h4 span.glyphicon-ok-sign"

  "instances.Starting": instancesPanelLocator "h4 span.glyphicon-play-circle"

  "instances.ProgressBarPullingFailed": (instanceName) ->
    locator: "xpath"
    value: "//span[@id='progress-bar-info-text-#{instanceName}' and .='Something went wrong while pulling images.']"

  "instances.Stop": instancesPanelLocator "a[title=Stop]"

  "instances.Delete": instancesPanelLocator "a[title=Delete]"

  "instances.Stop.Yes": instancesPanelLocator "button.stop-instance"

  "instances.Delete.Yes": instancesPanelLocator "button.clear-instance"

  "instances.StartLog": (instanceName, instanceVersion) ->
    locator: "css"
    value: "tr#controlPanel-#{instanceName}-#{instanceVersion} a[title=Logs]"
