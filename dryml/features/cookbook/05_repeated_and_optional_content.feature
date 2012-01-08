Feature: Repeated and optional content

  Scenario: The if tag
    Given a file named "example.dryml" with:
      """
      <% some_var = 'foo' %>
      <if test="&some_var"><p>some_var is true</p></if>
      <% some_other_var = '' %>
      <if test="&some_other_var"><p>some_other_var is true</p></if>
      """
    When I render "example.dryml"
    Then the output DOM should be:
      """
      <p>some_var is true</p>
      """

  Scenario: The else tag
    Given a file named "example.dryml" with:
      """
      <% some_var = 'foo' %>
      <if test="&some_var"><p>some_var is true</p></if>
      <else><p>some_var is false</p></else>
      <% some_other_var = '' %>
      <if test="&some_other_var"><p>some_other_var is true</p></if>
      <else><p>some_other_var is false</p></else>
      """
    When I render "example.dryml"
    Then the output DOM should be:
      """
      <p>some_var is true</p>
      <p>some_other_var is false</p>
      """

  Scenario: The unless tag
    Given a file named "example.dryml" with:
      """
      <% some_var = 'foo' %>
      <unless test="&some_var"><p>some_var is false</p></unless>
      <% some_other_var = '' %>
      <unless test="&some_other_var"><p>some_other_var is false</p></unless>
      """
    When I render "example.dryml"
    Then the output DOM should be:
      """
      <p>some_other_var is false</p>
      """

  Scenario: The if tag with a field
    Given a file named "example.dryml" with:
      """
      <if:author.name><p>author name is not blank</p></if>
      <% this.author.name = '' %>
      <if:author.name><p>author name is still not blank</p></if>
      <else><p>now it is</p></else>
      """
    When the current context is a blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <p>author name is not blank</p>
      <p>now it is</p>
      """

  Scenario: The if parameter
    Given a file named "example.dryml" with:
      """
      <% some_var = 'foo' %>
      <p if="&some_var">some_var is true</p>
      <% some_other_var = '' %>
      <p if="&some_other_var">some_other_var is true</p>
      """
    When I render "example.dryml"
    Then the output DOM should be:
      """
      <p>some_var is true</p>
      """

  Scenario: The unless parameter
    Given a file named "example.dryml" with:
      """
      <% some_var = 'foo' %>
      <p unless="&some_var">some_var is false</p>
      <% some_other_var = '' %>
      <p unless="&some_other_var">some_other_var is false</p>
      """
    When I render "example.dryml"
    Then the output DOM should be:
      """
      <p>some_other_var is false</p>
      """

  Scenario: The if parameter with a field - NOTE NO &
    Given a file named "example.dryml" with:
      """
      <p if="author.name">author name is not blank</p>
      <% this.author.name = '' %>
      <p if="author.name">author name is still not blank</p>
      <else><p>now it is</p></else>
      """
    When the current context is a blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <p>author name is not blank</p>
      <p>now it is</p>
      """

  Scenario: The if parameter without an argument
    Given a file named "example.dryml" with:
      """
      <do:author.name><p if>author name is not blank</p></do>
      <% this.author.name = '' %>
      <do:author.name><p if>author name is still not blank</p></do>
      <else><p>now it is</p></else>
      """
    When the current context is a blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <p>author name is not blank</p>
      <p>now it is</p>
      """

  Scenario: The if parameter without an argument applies to the surrounding context
    Given a file named "example.dryml" with:
      """
      <% this.author = '' %>
      <do:author if><p>first if is true</p></do>
      <do:author><do if><p>second if is true</p></do></do>
      """
    When the current context is a blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <p>first if is true</p>
      """

  Scenario: repeat tag
    Given a file named "example.dryml" with:
      """
      <repeat with="&[1,2,3,4]">
        <p><%= this %></p>
      </repeat>
      """
    When I render "example.dryml"
    Then the output DOM should be:
      """
      <p>1</p>
      <p>2</p>
      <p>3</p>
      <p>4</p>
      """

  Scenario: repeat attribute
    Given a file named "example.dryml" with:
      """
      <p repeat="&[1,2,3,4]"><%= this %></p>
      """
    When I render "example.dryml"
    Then the output DOM should be:
      """
      <p>1</p>
      <p>2</p>
      <p>3</p>
      <p>4</p>
      """

  Scenario: attributes on a repeated tag are re-evaluated at each iteration
    Given a file named "example.dryml" with:
      """
      <p repeat="&[1,2,3,4]" id="#{this}"><%= this %></p>
      """
    When I render "example.dryml"
    Then the output DOM should be:
      """
      <p id="1">1</p>
      <p id="2">2</p>
      <p id="3">3</p>
      <p id="4">4</p>
      """

  Scenario: even-odd scoped variable
    Given a file named "example.dryml" with:
      """
      <p repeat="&[1,2,3,4]" class="#{scope.even_odd}"><%= this %></p>
      """
    When I render "example.dryml"
    Then the output DOM should be:
      """
      <p class="odd">1</p>
      <p class="even">2</p>
      <p class="odd">3</p>
      <p class="even">4</p>
      """

  Scenario: repeating the implicit context with if
    Given a file named "example.dryml" with:
      """
      <do with="&[1,2,nil,4]">
        <repeat if><p id="#{this}"><%= this %></p></repeat>
      </do>
      <do with="&[]">
        <repeat if><p id="#{this}"><%= this %></p></repeat>
      </do>
      """
    When I render "example.dryml"
    Then the output DOM should be:
      """
      <p id="1">1</p>
      <p id="2">2</p>
      <p id=""></p>
      <p id="4">4</p>
      """

  Scenario: first_item? helper
    Given a file named "example.dryml" with:
      """
      <p repeat="&[1,2,3,4]" id="#{this}"><%= first_item? ? this*10 : this %></p>
      """
    When I render "example.dryml"
    Then the output DOM should be:
      """
      <p id="1">10</p>
      <p id="2">2</p>
      <p id="3">3</p>
      <p id="4">4</p>
      """

  Scenario: repeating over a hash sets this_key (not reliable on Ruby < 1.9)
    Given a file named "example.dryml" with:
      """
      <p repeat="&{:foo => 1, :bar => 2, :baz => 3}" id="#{this_key}"><%= this %></p>
      """
    When I render "example.dryml"
    Then the output DOM should be:
      """
      <p id="foo">1</p>
      <p id="bar">2</p>
      <p id="baz">3</p>
      """

