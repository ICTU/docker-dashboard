module.exports = 
  "agentStatus":                  # Green ball as status indicator for dashboard agent
    locator: "xpath"
    value: "//div[contains(text(), "Agent")]/../../div[1]/div[@class='led green bigger']"
  "etcdStatus":
    locator: "xpath"
    value: "//div[contains(text(), "ETCD")]/../../div[1]/div[@class='led green bigger']"
