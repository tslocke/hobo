Feature: Wrapping content

  Background:
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="card">
        <div class="card" merge-attrs>
          <h3 param="heading"><%= this.name %></h3>
          <div param="body"></div>
        </div>
      </def>
      """

  Scenario: wrapping content inside a parameter
    Given a file named "example.dryml" with:
      """
      <card>
        <heading:><a href="#{this.url}"><param-content for="heading"/></a></heading:>
      </card>
      """
    When I include the taglib "example_taglib"
    And the current context is a blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <div class="card">
        <h3 class="heading"><a href="/blog_posts/1">A Blog Post</a></h3>
        <div class="body"></div>
      </div>
      """

  Scenario: wrapping content outside a parameter
    Given a file named "example.dryml" with:
      """
      <card>
        <heading: replace>
          <div class="header">
            <heading: restore/>
            <p>ID: <%= this.id %></p>
          </div>
        </heading:>
      </card>
      """
    When I include the taglib "example_taglib"
    And the current context is a blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <div class="card">
        <div class="header">
          <h3 class="heading">A Blog Post</h3>
          <p>ID: 1</p>
        </div>
        <div class="body"></div>
      </div>
      """

