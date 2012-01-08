Feature: Customizing tags

  Scenario: a broken custom tag
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="card">
        <div class="card" merge-attrs>
          <h3 param="heading"><%= this.name %></h3>
          <div param="body"></div>
        </div>
      </def>

      <def tag="linked-card">
        <card>
          <heading: param><a href="&this.url"><%= this.name %></a></heading:>
        </card>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <linked-card class="emphasized">
        <body:><%= this.body %></body:>
      </linked-card>
      """
    When I include the taglib "example_taglib"
    And the current context is a blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <div class="card">
        <h3 class="heading">
          <a href="/blog_posts/1">A Blog Post</a>
        </h3>
        <div class="body"/>
      </div>
      """

  Scenario: merging attributes for a custom tag
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="card">
        <div class="card" merge-attrs>
          <h3 param="heading"><%= this.name %></h3>
          <div param="body"></div>
        </div>
      </def>

      <def tag="linked-card">
        <card merge-attrs>
          <heading: param><a href="&this.url"><%= this.name %></a></heading:>
        </card>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <linked-card class="emphasized">
        <body:><%= this.body %></body:>
      </linked-card>
      """
    When I include the taglib "example_taglib"
    And the current context is a blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <div class="card emphasized">
        <h3 class="heading">
          <a href="/blog_posts/1">A Blog Post</a>
        </h3>
        <div class="body"/>
      </div>
      """

  Scenario: merging attributes and adding params for a custom tag
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="card">
        <div class="card" merge-attrs>
          <h3 param="heading"><%= this.name %></h3>
          <div param="body"></div>
        </div>
      </def>

      <def tag="linked-card">
        <card merge-attrs>
          <heading: param><a href="&this.url"><%= this.name %></a></heading:>
          <body: param />
        </card>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <linked-card class="emphasized">
        <body:><%= this.body %></body:>
      </linked-card>
      """
    When I include the taglib "example_taglib"
    And the current context is a blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <div class="card emphasized">
        <h3 class="heading">
          <a href="/blog_posts/1">A Blog Post</a>
        </h3>
        <div class="body">
          Some body content
        </div>
      </div>
      """

  Scenario: merging attributes and params for a custom tag
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="card">
        <div class="card" merge-attrs>
          <h3 param="heading"><%= this.name %></h3>
          <div param="body"></div>
        </div>
      </def>

      <def tag="linked-card">
        <card merge-attrs merge-params>
          <heading: param><a href="&this.url"><%= this.name %></a></heading:>
        </card>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <linked-card class="emphasized">
        <body:><%= this.body %></body:>
      </linked-card>
      """
    When I include the taglib "example_taglib"
    And the current context is a blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <div class="card emphasized">
        <h3 class="heading">
          <a href="/blog_posts/1">A Blog Post</a>
        </h3>
        <div class="body">
          Some body content
        </div>
      </div>
      """

  Scenario: using the merge shorthand for a custom tag
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="card">
        <div class="card" merge-attrs>
          <h3 param="heading"><%= this.name %></h3>
          <div param="body"></div>
        </div>
      </def>

      <def tag="linked-card">
        <card merge>
          <heading: param><a href="&this.url"><%= this.name %></a></heading:>
        </card>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <linked-card class="emphasized">
        <body:><%= this.body %></body:>
      </linked-card>
      """
    When I include the taglib "example_taglib"
    And the current context is a blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <div class="card emphasized">
        <h3 class="heading">
          <a href="/blog_posts/1">A Blog Post</a>
        </h3>
        <div class="body">
          Some body content
        </div>
      </div>
      """

  Scenario: extending a tag
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="card">
        <div class="card" merge-attrs>
          <h3 param="heading"><%= this.name %></h3>
          <div param="body"></div>
        </div>
      </def>

      <extend tag="card">
        <old-card merge>
          <heading: param><a href="&this.url"><%= this.name %></a></heading:>
        </old-card>
      </extend>
      """
    And a file named "example.dryml" with:
      """
      <card class="emphasized">
        <body:><%= this.body %></body:>
      </card>
      """
    When I include the taglib "example_taglib"
    And the current context is a blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <div class="card emphasized">
        <h3 class="heading">
          <a href="/blog_posts/1">A Blog Post</a>
        </h3>
        <div class="body">
          Some body content
        </div>
      </div>
      """

  Scenario: extending a tag and aliasing a param
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="card">
        <div class="card" merge-attrs>
          <h3 param="heading"><%= this.name %></h3>
          <div param="body"></div>
        </div>
      </def>

      <extend tag="card">
        <old-card merge>
          <heading: param><a href="&this.url"><%= this.name %></a></heading:>
          <body: param="xbody" />
        </old-card>
      </extend>
      """
    And a file named "example.dryml" with:
      """
      <card class="emphasized">
        <xbody:><%= this.body %></xbody:>
      </card>
      """
    When I include the taglib "example_taglib"
    And the current context is a blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <div class="card emphasized">
        <h3 class="heading">
          <a href="/blog_posts/1">A Blog Post</a>
        </h3>
        <div class="body">
          Some body content
        </div>
      </div>
      """

  Scenario: extending a tag and using attributes (fails)
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="help-link" attrs="file">
        <a class="help" href="/help/#{file}.html" param="default"/>
      </def>

      <extend tag="help-link">
        <old-help-link merge>
          <img src="/images/#{file}.png" /><do param="default" />
        </old-help-link>
      </extend>
      """
    And a file named "example.dryml" with:
      """
      <help-link file="intro">Intro Help</help-link>
      """
    When I include the taglib "example_taglib"
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <a class="help" href="/help/intro.html"><img src="/images/intro.png" />Intro Help</a>
      """

  Scenario: extending a tag and using attributes take 2 (fails)
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="help-link" attrs="file">
        <a class="help" href="/help/#{file}.html" param="default"/>
      </def>

      <extend tag="help-link" attrs="file">
        <old-help-link merge>
          <img src="/images/#{file}.png" /><do param="default" />
        </old-help-link>
      </extend>
      """
    And a file named "example.dryml" with:
      """
      <help-link file="intro">Intro Help</help-link>
      """
    When I include the taglib "example_taglib"
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <a class="help" href="/help/intro.html"><img src="/images/intro.png" />Intro Help</a>
      """

