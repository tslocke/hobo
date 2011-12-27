Feature: replace parameters

  Scenario: simple replace parameter
    Given a file named "doctest_taglib.dryml" with:
    """
    <def tag="myp">
      <p param="foo" />
    </def>
    """
    And a file named "doctest.dryml" with:
    """
    <myp><foo: replace>Hello World</foo:></myp>
    """
    When I include the taglib "doctest_taglib"
    When I render "doctest.dryml"
    Then the output DOM should be:
    """
    Hello World
    """


