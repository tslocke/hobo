Feature: merge-params

  Scenario: merge-params with a param name
    Given a file named "doctest_taglib.dryml" with:
    """
    <def tag="myp">
      <p param="foo">This is foo</p>
      <p param="bar">This is bar</p>
    </def>
    """
    And a file named "doctest_extend.dryml" with:
    """
    <extend tag="myp">
      <old-myp merge-params="bar" />
    </extend>
    """
    And a file named "doctest.dryml" with:
    """
    <myp>
      <foo:>
        New stuff
      </foo:>
      <bar:>
        Brand-new bar
      </bar:>
    </myp>
    """
    When I include the taglib "doctest_taglib"
    And I include the taglib "doctest_extend"
    When I render "doctest.dryml"
    Then the output DOM should be:
    """
    <p class="foo">This is foo</p>
    <p class="bar">Brand-new bar</p>
    """

