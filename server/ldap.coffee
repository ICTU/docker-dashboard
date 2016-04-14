Meteor.startup ->
  LDAP_DEFAULTS.url = Meteor.settings?.ldap?.serverAddr || "ldap://ldap"
  LDAP_DEFAULTS.port = Meteor.settings?.ldap?.serverPort || "389"
  LDAP_DEFAULTS.base = Meteor.settings?.ldap?.baseDn || "dc=ictu,dc=nl"
  LDAP_DEFAULTS.superDn = Meteor.settings?.ldap?.superDn || ""
  LDAP_DEFAULTS.superPass = Meteor.settings?.ldap?.superPass || "123456"
  LDAP_DEFAULTS.admins = Meteor.settings?.ldap?.admins || ['']
  LDAP_DEFAULTS.searchResultsProfileMap = [
    {
      resultKey: "uid"
      profileProperty: "username"
    }
    {
      resultKey: "dn"
      profileProperty: "dn"
    }
    {
      resultKey: "mail"
      profileProperty: "email"
    }
  ]
