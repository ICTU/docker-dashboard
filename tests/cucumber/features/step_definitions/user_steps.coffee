module.exports = ->

  url = require 'url'

  @Before (event, callback) ->
    userData = username: 'piet', email: 'piet@test.com', password: 'test'
    @ddp.callAsync 'fixtures/user/create', [userData], ->
      @browser.url(url.resolve(process.env.HOST, '/'))
      .isExisting('#signIn').then (isExisting) =>
        if isExisting
          @browser
            .setValue('input[name=email]', userData.email)
            .setValue('input[name=password]', userData.password)
            .submitForm('#signIn')
          @browser.waitForExist('.user')
            .should.become(true).and.notify callback
        else callback()
