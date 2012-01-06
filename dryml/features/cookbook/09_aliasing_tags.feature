Feature: Aliasing tags

  Scenario: Simple alias
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="help-link" attrs="file">
        <a class="help" href="/help/#{file}.html" param="default"/>
      </def>

      <def tag="help" alias-of="help-link" />
      """
    And a file named "example.dryml" with:
      """
      <help file="intro">Intro Help</help>
      """
    When I include the taglib "example_taglib"
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <a class="help" href="/help/intro.html">Intro Help</a>
      """

  Scenario: Alias before extend
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="help-link" attrs="file">
        <a class="help" href="/help/#{file}.html" param="default"/>
      </def>

      <def tag="basic-help" alias-of="help-link" />

      <extend tag="help-link">
        <old-help-link merge>
          <img src="/images/logo.png" /><do param="default" />
        </old-help-link>
      </extend>
      """
    And a file named "example.dryml" with:
      """
      <basic-help file="basic">Basic Help</basic-help>
      <help-link file="intro">Intro Help</help-link>
      """
    When I include the taglib "example_taglib"
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <a class="help" href="/help/basic.html">Basic Help</a>
      <a class="help" href="/help/intro.html"><img src="/images/logo.png" />Intro Help</a>
      """

