Feature: Polymorphic tags

  Scenario: Using a polymorphic tag
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="card" polymorphic>
        <div class="card" merge-attrs>
          <h3 param="heading"><%= h this.to_s %></h3>
          <div param="body"></div>
        </div>
      </def>

      <def tag="card" for="BlogPost">
        <card merge>
          <heading: param><a href="#{this.url}"><%= this.title %></a></heading:>
          <body: param><do:author><%= this.name %></do></body:>
        </card>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <card />
      """
    When I include the taglib "example_taglib"
    And the current context is a blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <div class="card">
        <h3 class="heading"><a href="/blog_posts/1">A Blog Post</a></h3>
        <div class="body">Nobody</div>
      </div>
      """

  Scenario: Using a polymorphic tag for a subclass
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="card" polymorphic>
        <div class="card" merge-attrs>
          <h3 param="heading"><%= h this.to_s %></h3>
          <div param="body"></div>
        </div>
      </def>

      <def tag="card" for="BlogPost">
        <card merge>
          <heading: param><a href="#{this.url}"><%= this.title %></a></heading:>
          <body: param><do:author><%= this.name %></do></body:>
        </card>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <card />
      """
    When I include the taglib "example_taglib"
    And the current context is a special blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <div class="card">
        <h3 class="heading"><a href="/special_blog_posts/1">A Blog Post</a></h3>
        <div class="body">Nobody</div>
      </div>
      """


  Scenario: Using a polymorphic tag for a subclass with a customized tag (fails)
    issue 779 / https://github.com/tablatom/hobo/commit/aceb7afc384287b19e59ebb94020a2c509143c76
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="card" polymorphic>
        <div class="card" merge-attrs>
          <h3 param="heading"><%= h this.to_s %></h3>
          <div param="body"></div>
        </div>
      </def>

      <def tag="card" for="BlogPost">
        <card merge>
          <heading: param><a href="#{this.url}"><%= this.title %></a></heading:>
          <body: param><do:author><%= this.name %></do></body:>
        </card>
      </def>

      <def tag="card" for="SpecialBlogPost">
        <card class="special" for-type="BlogPost" merge/>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <card class="more_special" />
      """
    When I include the taglib "example_taglib"
    And the current context is a special blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <div class="card special more_special">
        <h3 class="heading"><a href="/special_blog_posts/1">A Blog Post</a></h3>
        <div class="body">Nobody</div>
      </div>
      """

  Scenario: using call-tag to call a polymorphic tag
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="card" polymorphic>
        <div class="card" merge-attrs>
          <h3 param="heading"><%= h this.to_s %></h3>
          <div param="body"></div>
        </div>
      </def>

      <def tag="card" for="BlogPost">
        <card merge>
          <heading: param><a href="#{this.url}"><%= this.title %></a></heading:>
          <body: param><do:author><%= this.name %></do></body:>
        </card>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <call-tag tag="card" />
      """
    When I include the taglib "example_taglib"
    And the current context is a blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <div class="card">
        <h3 class="heading"><a href="/blog_posts/1">A Blog Post</a></h3>
        <div class="body">Nobody</div>
      </div>
      """

  Scenario: using call-tag to call a polymorphic tag with an explicit type (fails)
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="card" polymorphic>
        <div class="card" merge-attrs>
          <h3 param="heading"><%= h this.to_s %></h3>
          <div param="body"></div>
        </div>
      </def>

      <def tag="card" for="BlogPost">
        <card merge>
          <heading: param><a href="#{this.url}"><%= this.title %></a></heading:>
          <body: param><do:author><%= this.name %></do></body:>
        </card>
      </def>
      """
    And a file named "example.dryml" with:
      """
      <call-tag tag="card" for-type="BlogPost" />
      """
    When I include the taglib "example_taglib"
    And the current context is a special blog post
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <div class="card">
        <h3 class="heading"><a href="/special_blog_posts/1">A Blog Post</a></h3>
        <div class="body">Nobody</div>
      </div>
      """

