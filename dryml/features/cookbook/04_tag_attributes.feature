Feature: Tag attributes

  Scenario: A tag with one attribute
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="help-link" attrs="file">
        <a class="help" href="/help/#{file}.html" param="default"/>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <help-link file="intro">Introductory Help</help-link>
      """
    When I include the taglib "example_taglib"
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <a class="help" href="/help/intro.html">Introductory Help</a>
      """

  Scenario: A tag with a boolean attribute
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="help-link" attrs="file, new-window">
        <a class="help" href="/help/#{file}.html" target="#{new_window ? '_blank' : '_self' }" param="default"/>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <help-link file="intro" new-window="&true">Introductory Help In A New Window</help-link>
      <help-link file="intro" new-window="&false">Introductory Help</help-link>
      """
    When I include the taglib "example_taglib"
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <a class="help" href="/help/intro.html" target="_blank">Introductory Help In A New Window</a>
      <a class="help" href="/help/intro.html" target="_self">Introductory Help</a>
      """

  Scenario: A tag with a flag attribute
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="help-link" attrs="file, new-window">
        <a class="help" href="/help/#{file}.html" target="#{new_window ? '_blank' : '_self' }" param="default"/>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <help-link file="intro" new-window>Introductory Help In A New Window</help-link>
      <help-link file="intro">Introductory Help</help-link>
      """
    When I include the taglib "example_taglib"
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <a class="help" href="/help/intro.html" target="_blank">Introductory Help In A New Window</a>
      <a class="help" href="/help/intro.html" target="_self">Introductory Help</a>
      """

  Scenario: Using merge-attrs
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="markdown-help">
        <a href="http://daringfireball.net/..." merge-attrs param="default"/>
      </def>
      """
    And a file named "example.dryml" with:
      """
      Add formatting using <markdown-help target="_blank">markdown</markdown-help>
      """
    When I include the taglib "example_taglib"
    And I render "example.dryml"
    Then the output DOM should be:
      """
      Add formatting using <a href="http://daringfireball.net/..." target="_blank">markdown</a>
      """

  Scenario: Using merge-attrs and attributes_for
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="help-link" attrs="file, new-window">
        <a class="help" href="/help/#{file}.html" target="#{new_window ? '_blank' : '_self' }" param="default"/>
      </def>

      <def tag="decorated-help" attrs="image, alt">
        <help-link merge-attrs="&attributes - attrs_for(:help_link)">
          <img src="/images/#{image}.png" alt="#{alt || image}" /><do param="default"/>
        </help-link>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <decorated-help image="intro" file="intro" new-window>Introductory Help In A New Window</decorated-help>
      """
    When I include the taglib "example_taglib"
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <a class="help" href="/help/.html" target="_self"><img alt="intro" src="/images/intro.png"/>Introductory Help In A New Window</a>
      """

  Scenario: Merging the class attribute
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="help-link" attrs="file">
        <a class="help" href="/help/#{file}.html" param="default" merge-attrs/>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <help-link file="intro" class="important">Introductory Help</help-link>
      """
    When I include the taglib "example_taglib"
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <a class="help important" href="/help/intro.html">Introductory Help</a>
      """

