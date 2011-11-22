Feature: Static tags render correctly

  Scenario: Static tag with static attributes

    Given a file named "static_tag.dryml" with:
      """
      <div class="foo">
        FOO
      </div>
      """
    When I render "static_tag.dryml"
    Then the output DOM should be:
      """
      <div class="foo">
        FOO
      </div>
      """

  Scenario: Static tag with an interpolated attribute

    Given a file named "static_tag.dryml" with:
      """
      <% some_var = 'foo' %>
      <div class="#{some_var}">
        FOO
      </div>
      """
    When I render "static_tag.dryml"
    Then the output DOM should be:
      """
      <div class="foo">
        FOO
      </div>
      """

