Feature: Pseudo-parameters: before, after, append and prepend

  Background:
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="page">
        <body>
          <h1 param="heading"><%= this.name %></h1>
          <div param="content"></div>
        </body>
      </def>

      <def tag="help-link" attrs="file, new-window">
        <a class="help" href="/help/#{file}.html" target="#{new_window ? '_blank' : '_self' }" param="default"/>
      </def>

      <def tag="decorated-help" attrs="image, alt">
        <help-link merge-attrs="&attributes - attrs_for(:help_link)">
          <img src="/images/#{image}.png" alt="#{alt || image}" /><do param="default"/>
        </help-link>
      </def>

      <def tag="helpful-page">
        <page merge>
          <content:>
            <decorated-help image="intro" param>Intro Help</decorated-help>
          </content:>
        </page>
      </def>
      """
    When I include the taglib "example_taglib"

  Scenario: append parameter
    Given a file named "example.dryml" with:
      """
      <page>
        <append-heading:> -- The Hobo Blog</append-heading:>
        <content:>
          <%= this.body %>
        </content>
      </page>
      """
    When the current context is a blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <body>
        <h1 class="heading">A Blog Post -- The Hobo Blog</h1>
        <div class="content">
          Some body content
        </div>
      </body>
      """

  Scenario: prepend parameter
    Given a file named "example.dryml" with:
      """
      <page>
        <prepend-heading:>The Hobo Blog -- </prepend-heading:>
        <content:>
          <%= this.body %>
        </content>
      </page>
      """
    When the current context is a blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <body>
        <h1 class="heading">The Hobo Blog -- A Blog Post</h1>
        <div class="content">
          Some body content
        </div>
      </body>
      """

  Scenario: before parameter
    Given a file named "example.dryml" with:
      """
      <page>
        <before-heading:><h1>The Hobo Blog</h1></before-heading:>
        <content:>
          <%= this.body %>
        </content>
      </page>
      """
    When the current context is a blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <body>
        <h1>The Hobo Blog</h1>
        <h1 class="heading">A Blog Post</h1>
        <div class="content">
          Some body content
        </div>
      </body>
      """

  Scenario: after parameter
    Given a file named "example.dryml" with:
      """
      <page>
        <after-heading:><h1>The Hobo Blog</h1></after-heading:>
        <content:>
          <%= this.body %>
        </content>
      </page>
      """
    When the current context is a blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <body>
        <h1 class="heading">A Blog Post</h1>
        <h1>The Hobo Blog</h1>
        <div class="content">
          Some body content
        </div>
      </body>
      """

  Scenario: append parameter uses the default parameter
    Given a file named "example.dryml" with:
      """
      <helpful-page>
        <append-decorated-help:> And More</append-decorated-help:>
      </helpful-page>
      """
    When the current context is a blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <body>
        <h1 class="heading">A Blog Post</h1>
        <div class="content">
          <a class="help" href="/help/.html" target="_self">
            <img alt="intro" src="/images/intro.png"/>Intro Help And More
          </a>
        </div>
      </body>
      """

  Scenario: a replace parameter
    Given a file named "example.dryml" with:
      """
      <page>
        <heading: replace><h2>My Awesome Page</h2></heading:>
        <content:>Some content</content:>
      </page>
      """
    When I render "example.dryml"
    Then the output DOM should be:
      """
      <body>
        <h2>My Awesome Page</h2>
        <div class="content">Some content</div>
      </body>
      """

  Scenario: a replace parameter with no content
    Given a file named "example.dryml" with:
      """
      <page>
        <heading: replace />
        <content:>Some content</content:>
      </page>
      """
    When I render "example.dryml"
    Then the output DOM should be:
      """
      <body>
        <div class="content">Some content</div>
      </body>
      """

  Scenario: using without
    Given a file named "example.dryml" with:
      """
      <page without-heading>
        <content:>Some content</content:>
      </page>
      """
    When I render "example.dryml"
    Then the output DOM should be:
      """
      <body>
        <div class="content">Some content</div>
      </body>
      """

