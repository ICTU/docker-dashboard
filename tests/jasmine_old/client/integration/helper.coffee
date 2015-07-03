@TestHelper =
  # Expectations
  expectTextToEqual: (locator, expected) -> expect($(locator).text().trim()).toEqual expected
  expectValueToEqual: (locator, expected) -> expect($(locator).val()).toEqual expected
  expectNumElementsToEqual: (locator, numElem) -> expect($(locator).size()).toEqual numElem

  # Actions
  clickLink: (args) ->
    if args.url
      $("a[href=\"#{args.url}\"]").click()
    else if args.linkText
      $("a:contains('#{args.text}')").click()
    else args.title
      $("a[title=#{args.title}]").click()
  clickButton: (locator) -> $("button[#{locator}]").click()
  triggerInput: (locator, value) -> $(locator).val(value).trigger 'input'

  # Timing
  defer: (f, t = 0) -> setTimeout f, t
  deferLong: (f) -> @defer f, 2000

@TH = TestHelper

@Aut
  appsPage:
    remove = (name, ver) ->
      $("a[data-target='#appPanel-#{name}']::after").click()
      $("#appPanel-#{name} ").parent().$('::after').click()
