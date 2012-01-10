Feature: Local and scoped variables

  Scenario: local variables
    Given a file named "example.dryml" with:
      """
      <% erb_local = 'Hello World' %>
      <set dryml-local="Hello World" />
      <p><%= erb_local %></p>
      <p><%= dryml_local %></p>
      """
    When I render "example.dryml"
    Then the output DOM should be:
      """
      <p>Hello World</p>
      <p>Hello World</p>
      """

  Scenario: scoped variables
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="show-the-var">
        <p><%= scope.the_var %></p>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <show-the-var />
      <set-scoped the-var="foo">
        <show-the-var />
        <set-scoped the-var="bar">
          <show-the-var />
        </set-scoped>
        <show-the-var />
      </set-scoped>
      <show-the-var />
      """
    When I include the taglib "example_taglib"
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <p></p>
      <p>foo</p>
      <p>bar</p>
      <p>foo</p>
      <p></p>
      """

  Scenario: collecting content in a scoped var
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="tab-item" attrs="id, name">
        <% scope.tabs_content << [id, parameters.default] %>
        <li><a href="##{id}"><%= name %></a></li>
      </def>

      <def tag="tabs">
        <set-scoped tabs-content="&[]">
          <ul class="tabs">
            <do param="default" />
          </ul>
          <repeat with="&scope.tabs_content">
            <div id="#{this[0]}">
              <%= this[1] %>
            </div>
          </repeat>
        </set-scoped>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <tabs>
        <tab-item id="foo" name="First Item">
          <p>Foo Foo Foo</p>
        </tab-item>
        <tab-item id="bar" name="Second Item">
          <p>Bar Bar Bar</p>
        </tab-item>
        <tab-item id="baz" name="Third Item">
          <p>Baz Baz Baz</p>
        </tab-item>
      </tabs>
      """
    When I include the taglib "example_taglib"
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <ul class="tabs">
        <li><a href="#foo">First Item</a></li>
        <li><a href="#bar">Second Item</a></li>
        <li><a href="#baz">Third Item</a></li>
      </ul>
      <div id="foo">
        <p>Foo Foo Foo</p>
      </div>
      <div id="bar">
        <p>Bar Bar Bar</p>
      </div>
      <div id="baz">
        <p>Baz Baz Baz</p>
      </div>
      """

