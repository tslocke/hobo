Feature: The implicit context
  Background:
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="view"><%= h this.to_s %></def>

      <def tag="l"><a href="#{this.url}" param="default"/></def>

      <def tag="page">
        <html>
          <head>
            <title>My Blog</title>
          </head>
          <body param="content"/>
        </html>
      </def>
      """

  Scenario: Rendering a blog post
    Given a file named "show.dryml" with:
      """
      <page>
        <content:>
          <h2><view:title/></h2>
          <div class="details">
            Published by <l:author><view:name/></l> on <view:published-at/>.
          </div>
          <div class="post-body">
            <view:body/>
          </div>
        </content:>
      </page>
      """
    When I include the taglib "example_taglib"
    And the current context is a blog post
    And I render "show.dryml"
    Then the output DOM should be:
      """
      <html>
        <head>
          <title>My Blog</title>
        </head>
        <body class="content">
          <h2>A Blog Post</h2>
          <div class="details">
          Published by <a href="/authors/1">Nobody</a> on 2011-12-30 10:25:00 UTC.
          </div>
          <div class="post-body">
            Some body content
          </div>
        </body>
      </html>
      """

  Scenario: Rendering a blog post using only with
    Given a file named "show.dryml" with:
      """
      <page>
        <content:>
          <h2><view with="&this.title"/></h2>
          <div class="details">
            Published by <l with="&this.author"><view with="&this.name"/></l>
            on <view with="&this.published_at"/>.
          </div>
          <div class="post-body">
            <view with="&this.body"/>
          </div>
        </content:>
      </page>
      """
    When I include the taglib "example_taglib"
    And the current context is a blog post
    And I render "show.dryml"
    Then the output DOM should be:
      """
      <html>
        <head>
          <title>My Blog</title>
        </head>
        <body class="content">
          <h2>A Blog Post</h2>
          <div class="details">
          Published by <a href="/authors/1">Nobody</a> on 2011-12-30 10:25:00 UTC.
          </div>
          <div class="post-body">
            Some body content
          </div>
        </body>
      </html>
      """

  Scenario: Rendering a blog post using only field
    Given a file named "show.dryml" with:
      """
      <page>
        <content:>
          <h2><view field="title"/></h2>
          <div class="details">
            Published by <l field="author"><view field="name"/></l>
            on <view field="published_at"/>.
          </div>
          <div class="post-body">
            <view field="body"/>
          </div>
        </content:>
      </page>
      """
    When I include the taglib "example_taglib"
    And the current context is a blog post
    And I render "show.dryml"
    Then the output DOM should be:
      """
      <html>
        <head>
          <title>My Blog</title>
        </head>
        <body class="content">
          <h2>A Blog Post</h2>
          <div class="details">
          Published by <a href="/authors/1">Nobody</a> on 2011-12-30 10:25:00 UTC.
          </div>
          <div class="post-body">
            Some body content
          </div>
        </body>
      </html>
      """

  Scenario: field chains
    Given a file named "show.dryml" with:
      """
      <div><do:author.name><view /></do></div>
      <div><do field="author.name"><view /></do></div>
      """
    When I include the taglib "example_taglib"
    And the current context is a blog post
    And I render "show.dryml"
    Then the output DOM should be:
      """
      <div>Nobody</div>
      <div>Nobody</div>
      """

  Scenario: this_field and this_parent
    Given a file named "show.dryml" with:
      """
      <div>
        <do with="&this.author.name">
          <div><view /></div>
          <div><%= this_parent.class.name %></div>
          <div><%= this_field %></div>
        </do>
      </div>
      <div>
        <do with="&this.author" field="name">
          <div><view /></div>
          <div><%= this_parent.class.name %></div>
          <div><%= this_field %></div>
        </do>
      </div>
      """
    When I include the taglib "example_taglib"
    And the current context is a blog post
    And I render "show.dryml"
    Then the output DOM should be:
      """
      <div>
        <div>Nobody</div>
        <div>NilClass</div>
        <div></div>
      </div>
      <div>
        <div>Nobody</div>
        <div>Author</div>
        <div>name</div>
      </div>
      """

  Scenario: indexing into a collection
    Given a file named "show.dryml" with:
      """
      <div><do field="1"><view /></do></div>
      <div><do field="3"><view /></do></div>
      """
    When I include the taglib "example_taglib"
    And the current context is an array
    And I render "show.dryml"
    Then the output DOM should be:
      """
      <div>bar</div>
      <div>blam</div>
      """

  Scenario: repeating on a collection stores the index in this_field
    Given a file named "show.dryml" with:
      """
      <repeat>
        <div>
          <span><%= this_field %></span>
          <span><view /></span>
        </div>
      </repeat>
      """
    When I include the taglib "example_taglib"
    And the current context is an array
    And I render "show.dryml"
    Then the output DOM should be:
      """
        <div>
          <span>0</span>
          <span>foo</span>
        </div>
        <div>
          <span>1</span>
          <span>bar</span>
        </div>
        <div>
          <span>2</span>
          <span>baz</span>
        </div>
        <div>
          <span>3</span>
          <span>blam</span>
        </div>
        <div>
          <span>4</span>
          <span>mumble</span>
        </div>
      """
