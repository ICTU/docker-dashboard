module.exports =
    # Navigation bar links
    "menu.Apps":
      locator: "linkText"
      value: "Apps"
    "menu.Instances":
      locator: "linkText"
      value: "Instances"
    "menu.AppStore":
      locator: "linkText"
      value: "App Store"
    "menu.Storage":
      locator: "linkText"
      value: "Storage"
    "menu.Configuration":
      locator: "linkText"
      value: "Configuration"
    "menu.Status":
      locator: "linkText"
      value: "Status"
    "menu.Login":
      locator: "css"
      value: "i.glyphicon-user"


    # Login box
    "login.Username":
      locator: "id"
      value: "username"
    "login.Password":
      locator: "id"
      value: "password"
    "login.acceptTerms":
      locator: "id"
      value: "accept_terms"
    "login.Submit":
      locator: "id"
      value: "btnLogin"
    "login.GravatarLink": (username) ->
      locator: "xpath"
      value: "//a[img[@class='avatar'] and text()='#{username}']"

    # Toolbox links
    "toolbox.NewApp":
      locator: "linkText"
      value: "New App"
    "toolbox.NewInstance":
      locator: "linkText"
      value: "New Instance"

    # Page Headers
    "page.title":
      locator: "css"
      value: ".pageTitle"

    "statusHeader":
      locator: "xpath"
      value: "//div[@class='container statusPage']//h3[contains(text(), 'Status')]"
