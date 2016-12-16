{ assert } = require 'meteor/practicalmeteor:chai'
{ AppDef } = require './utils'

testAppDef =
  def: """
    name: nginx
    version: latest

    #tags: autorun infra

    www:
      image: nginx
      endpoint: :80
      environment:
        - PORT=5000
        - URL=http://www.nginx.project.ictu
      depends_on:
        - db
      volumes:
        - /simple/path
        - /with/qualifier:ro
        - /with/mapping:/internal/path
        - /with/mapping/and/qualifier:/internal/path:rw
        - /with/deprecated/shared/qualifier:shared
        - /with/deprecated/do_not_persist/qualifier:do_not_persist

    db:
      image: mysql:5.6
      environment:
        USER: root
        PASS: really_secret
      volumes:
        - /var/lib/mysql
      enable_ssh: true
  """

expected =
  bigboatCompose: """
    name: nginx
    version: latest
    www:
      endpoint: ':80'
    db:
      enable_ssh: true
    tags:
      - autorun
      - infra

  """
  dockerCompose: """
    www:
      image: nginx
      environment:
        - PORT=5000
        - URL=http://www.nginx.project.ictu
      depends_on:
        - db
      volumes:
        - /www/simple/path:/simple/path
        - /www/with/qualifier:/with/qualifier:ro
        - /www/with/mapping:/internal/path
        - /www/with/mapping/and/qualifier:/internal/path:rw
        - /www/with/deprecated/shared/qualifier:/with/deprecated/shared/qualifier
        - /www/with/deprecated/do_not_persist/qualifier:/with/deprecated/do_not_persist/qualifier


    db:
      image: mysql:5.6
      environment:
        USER: root
        PASS: really_secret
      volumes:
        - /db/var/lib/mysql:/var/lib/mysql
  """


describe 'AppDef', ->
  describe 'toCompose', ->
    toCompose = AppDef.toCompose
    it 'should work', ->
      actual = toCompose testAppDef
      assert.equal actual.dockerCompose, expected.dockerCompose
      assert.equal actual.bigboatCompose, expected.bigboatCompose
