Feature: Defining simple tags

  Scenario: A simple tag
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="page">
        <html>
          <head>
            <title>My Blog</title>
          </head>
          <body>
            <h1>My Famous Blog!</h1>
            <h2><%= @post_title %></h2>

            <div class="post-body">
              <%= @post_body %>
            </div>
          </body>
        </html>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <% @post_title = 'FOO' %>
      <% @post_body = 'Blah blah blah' %>
      <page />
      """
    When I include the taglib "example_taglib"
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <html>
        <head>
          <title>My Blog</title>
        </head>
        <body>
          <h1>My Famous Blog!</h1>
          <h2>FOO</h2>
          <div class="post-body">
            Blah blah blah
          </div>
        </body>
      </html>
      """

  Scenario: a simple tag with a param
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="page">
        <html>
          <head>
            <title>My Blog</title>
          </head>
          <body param/>
        </html>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <% @post_title = 'FOO' %>
      <% @post_body = 'Blah blah blah' %>
      <page>
        <body:>
          <h1>My Famous Blog!</h1>
          <h2><%= @post_title %></h2>

          <div class="post-body">
            <%= @post_body %>
          </div>
        </body:>
      </page>
      """
    When I include the taglib "example_taglib"
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <html>
        <head>
          <title>My Blog</title>
        </head>
        <body>
          <h1>My Famous Blog!</h1>
          <h2>FOO</h2>
          <div class="post-body">
            Blah blah blah
          </div>
        </body>
      </html>
      """
  Scenario: a simple tag with a renamed param
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="page">
        <html>
          <head>
            <title>My Blog</title>
          </head>
          <body param="content"/>
        </html>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <% @post_title = 'FOO' %>
      <% @post_body = 'Blah blah blah' %>
      <page>
        <content:>
          <h1>My Famous Blog!</h1>
          <h2><%= @post_title %></h2>

          <div class="post-body">
            <%= @post_body %>
          </div>
        </content:>
      </page>
      """
    When I include the taglib "example_taglib"
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <html>
        <head>
          <title>My Blog</title>
        </head>
        <body class="content">
          <h1>My Famous Blog!</h1>
          <h2>FOO</h2>
          <div class="post-body">
            Blah blah blah
          </div>
        </body>
      </html>
      """

  Scenario: a simple tag with two parameters
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="page">
        <html>
          <head>
            <title>My Blog</title>
          </head>
          <body>
            <div param="content" />
            <div param="aside" />
          </body>
        </html>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <% @post_title = 'FOO' %>
      <% @post_body = 'Blah blah blah' %>
      <page>
        <content:>
          <h1>My Famous Blog!</h1>
          <h2><%= @post_title %></h2>

          <div class="post-body">
            <%= @post_body %>
          </div>
        </content:>
        <aside:>
          Here is some aside content!
        </aside:>
      </page>
      """
    When I include the taglib "example_taglib"
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <html>
        <head>
          <title>My Blog</title>
        </head>
        <body>
          <div class="content">
            <h1>My Famous Blog!</h1>
            <h2>FOO</h2>
            <div class="post-body">
              Blah blah blah
            </div>
          </div>
          <div class="aside">
            Here is some aside content!
          </div>
        </body>
      </html>
      """

  Scenario: a simple tag with default parameter content
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="page">
        <html>
          <head>
            <title param>My Blog</title>
          </head>
          <body param/>
        </html>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <% @post_title = 'FOO' %>
      <% @post_body = 'Blah blah blah' %>
      <page>
        <title:>My VERY EXCITING Blog</title:>
        <body:>
          <h1>My Famous Blog!</h1>
          <h2><%= @post_title %></h2>

          <div class="post-body">
            <%= @post_body %>
          </div>
        </body:>
      </page>
      """
    When I include the taglib "example_taglib"
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <html>
        <head>
          <title>My VERY EXCITING Blog</title>
        </head>
        <body>
          <h1>My Famous Blog!</h1>
          <h2>FOO</h2>
          <div class="post-body">
            Blah blah blah
          </div>
        </body>
      </html>
      """

  Scenario: a simple tag with nested parameters
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="page">
        <html>
          <head>
            <title>My Blog</title>
          </head>
          <body param>
            <div param="content" />
            <div param="aside" />
          </body>
        </html>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <% @post_title = 'FOO' %>
      <% @post_body = 'Blah blah blah' %>
      <page>
        <content:>
          <h1>My Famous Blog!</h1>
          <h2><%= @post_title %></h2>

          <div class="post-body">
            <%= @post_body %>
          </div>
        </content:>
        <aside:>
          Here is some aside content!
        </aside:>
      </page>
      """
    When I include the taglib "example_taglib"
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <html>
        <head>
          <title>My Blog</title>
        </head>
        <body>
          <div class="content">
            <h1>My Famous Blog!</h1>
            <h2>FOO</h2>
            <div class="post-body">
              Blah blah blah
            </div>
          </div>
          <div class="aside">
            Here is some aside content!
          </div>
        </body>
      </html>
      """

  Scenario: a simple tag with nested parameters, using the outside param
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="page">
        <html>
          <head>
            <title>My Blog</title>
          </head>
          <body param>
            <div param="content" />
            <div param="aside" />
          </body>
        </html>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <% @post_title = 'FOO' %>
      <% @post_body = 'Blah blah blah' %>
      <page>
        <body:>
          This is body content!
        </body:>
      </page>
      """
    When I include the taglib "example_taglib"
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <html>
        <head>
          <title>My Blog</title>
        </head>
        <body>
          This is body content!
        </body>
      </html>
      """

  Scenario: a simple tag with a default parameter
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="page">
        <html>
          <head>
            <title>My Blog</title>
          </head>
          <body param="default" />
        </html>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <% @post_title = 'FOO' %>
      <% @post_body = 'Blah blah blah' %>
      <page>
        <h1>My Famous Blog!</h1>
        <h2><%= @post_title %></h2>

        <div class="post-body">
          <%= @post_body %>
        </div>
      </page>
      """
    When I include the taglib "example_taglib"
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <html>
        <head>
          <title>My Blog</title>
        </head>
        <body>
          <h1>My Famous Blog!</h1>
          <h2>FOO</h2>
          <div class="post-body">
            Blah blah blah
          </div>
        </body>
      </html>
      """


