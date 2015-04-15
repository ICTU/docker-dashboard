@TestHelper =
  # Expectations
  expectTextToEqual: (locator, expected) -> expect($(locator).text().trim()).toEqual expected
  expectValueToEqual: (locator, expected) -> expect($(locator).val()).toEqual expected
  expectNumElementsToEqual: (locator, numElem) -> expect($(locator).size()).toEqual numElem

  # Actions
  clickLink: (url) -> $("a[href=\"#{url}\"]").click()
  clickButton: (locator) -> $("button[#{locator}]").click()
  triggerInput: (locator, value) -> $(locator).val(value).trigger 'input'

  # Timing
  defer: (f, t = 0) -> setTimeout f, t
  deferLong: (f) -> @defer f, 2000

@TH = TestHelper
