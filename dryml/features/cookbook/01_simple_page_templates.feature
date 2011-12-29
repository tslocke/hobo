Feature: Simple page templates and ERB

  Scenario: Interpolating in HTML attributes
    Given a file named "example.dryml" with:
      """
      <% my_url = '/foo/bar' %>
      <a href="#{my_url}">Link Text</a>
      """
    When I render "example.dryml"
    Then the output DOM should be:
      """
      <a href="/foo/bar">Link Text</a>
      """

  Scenario: Merging a hash of attributes
    Given a file named "example.dryml" with:
      """
      <% hash = { :action => '/foo/bar', :method => 'get' } %>
      <form merge-attrs="&hash">
        <input type="text" name="wut" />
      </form>
      """
    When I render "example.dryml"
    Then the output DOM should be:
      """
      <form action="/foo/bar" method="get">
        <input type="text" name="wut" />
      </form>
      """

  Scenario: Dynamically calling tags
    Given a file named "example.dryml" with:
      """
      <% my_tag_name = "div" %>
      <%= raw "<#{my_tag_name}>" %>FOO<%= raw "</#{my_tag_name}>" %>
      <call-tag tag="&my_tag_name">BAR</call-tag>
      """
    When I render "example.dryml"
    Then the output DOM should be:
      """
      <div>FOO</div>
      <div>BAR</div>
      """

