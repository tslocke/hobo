Feature: Doctest examples

  Scenario: plain text
    Given a file named "doctest.dryml" with:
    """
    hi
    """
    When I render "doctest.dryml"
    Then the output DOM should be:
    """
    hi
    """

  Scenario: single ERB output tag
    Given a file named "doctest.dryml" with:
    """
    <%= this %>
    """
    And the local variable "this" has the value "hello"
    When I render "doctest.dryml"
    Then the output DOM should be:
    """
    hello
    """

  Scenario: if-else
    Given a file named "doctest.dryml" with:
    """
    <if test="&true">
      Hi
    </if>
    <else>
      Bye
    </else>
    """
    When I render "doctest.dryml"
    Then the output DOM should be:
    """
    Hi
    """

  Scenario: repeating tags
    Given a file named "doctest.dryml" with:
    """
    <repeat with="&[1,2,3]">
      <span><%= this %></span>
    </repeat>
    """
    When I render "doctest.dryml"
    Then the output DOM should be:
    """
    <span>1</span>
    <span>2</span>
    <span>3</span>
    """

  Scenario: defining a tag with a default parameter
    Given a file named "doctest.dryml" with:
    """
    <def tag="myp">
      <p param="default"/>
    </def>
    <myp>Hi</myp>
    """
    When I render "doctest.dryml"
    Then the output DOM should be:
    """
    <p>
      Hi
    </p>
    """

  Scenario: calling a tag using call-tag
    Given a file named "doctest.dryml" with:
    """
    <def tag="myp">
      <p param="default" />
    </def>
    <call-tag tag="myp">
      Hi
    </call-tag>
    """
    When I render "doctest.dryml"
    Then the output DOM should be:
    """
    <p>
      Hi
    </p>
    """

  Scenario: wrapping content with a custom tag
    Given a file named "doctest.dryml" with:
    """
    <def tag="myp">
      <p param="default" />
    </def>
    <wrap tag="myp" when="&true">
      img
    </wrap>
    """
    When I render "doctest.dryml"
    Then the output DOM should be:
    """
    <p>
      img
    </p>
    """

  Scenario: extending a tag (fails)
    Given a file named "doctest_taglib.dryml" with:
    """
    <def tag="myp">
      <p param="default" />
    </def>
    """
    And a file named "doctest_extend.dryml" with:
    """
    <extend tag="myp">
      <old-myp merge>
        <default: replace>Hello <default restore /></default:>
      </old-myp>
    </extend>
    """
    And a file named "doctest.dryml" with:
    """
    <myp>New World</myp>
    """
    When I include the taglib "doctest_taglib"
    And I include the taglib "doctest_extend"
    When I render "doctest.dryml"
    Then the output DOM should be:
    """
    <p>Hello New World</p>
    """

  Scenario: extending a tag with a non-default param (fails)
    Given a file named "doctest_taglib.dryml" with:
    """
    <def tag="myp">
      <p param="foo" />
    </def>
    """
    And a file named "doctest_extend.dryml" with:
    """
    <extend tag="myp">
      <old-myp merge>
        <foo:>
          Hello <param-content for="foo" />
        </foo:>
      </old-myp>
    </extend>
    """
    And a file named "doctest.dryml" with:
    """
    <myp><foo:>New World</foo:></myp>
    """
    When I include the taglib "doctest_taglib"
    And I include the taglib "doctest_extend"
    When I render "doctest.dryml"
    Then the output DOM should be:
    """
    <p class="foo">Hello New World</p>
    """

  Scenario: param-content-restore from an output context
    Given a file named "doctest_taglib.dryml" with:
    """
    <def tag="myp">
      <p param="foo">World</p>
    </def>
    """
    And a file named "doctest.dryml" with:
    """
    <myp>
      <foo:>
        Hello <param-content for="foo" />
      </foo:>
    </myp>
    """
    When I include the taglib "doctest_taglib"
    When I render "doctest.dryml"
    Then the output DOM should be:
    """
    <p class="foo">Hello World</p>
    """


