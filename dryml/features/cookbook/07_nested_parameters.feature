Feature: Nested parameters

  Background:
    Given a file named "example_taglib.dryml" with:
      """
      <def tag="card">
        <div class="card" merge-attrs>
          <h3 param="heading"><%= this.name %></h3>
          <div param="body"></div>
        </div>
      </def>

      <def tag="collection">
        <h2 param="heading"></h2>
        <ul>
          <li repeat>
            <card param />
          </li>
        </ul>
      </def>

      <def tag="index-page">
        <html>
          <head><title param>Index Page</title></head>
          <body>
            <h1 param="heading"></h1>
            <collection param />
          </body>
        </html>
      </def>
      """
    When I include the taglib "example_taglib"

  Scenario: Single level of nesting
    Given a file named "example.dryml" with:
      """
      <collection>
        <heading:>Discussions</heading:>
        <card:><body:><%= this.posts.length %> posts</body:></card:>
      </collection>
      """
    When the current context is a list of discussions
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <h2 class="heading">Discussions</h2>
      <ul>
        <li>
          <div class="card">
            <h3 class="heading">Discussion 1</h3>
            <div class="body">1 posts</div>
          </div>
        </li>
        <li>
          <div class="card">
            <h3 class="heading">Discussion 2</h3>
            <div class="body">2 posts</div>
          </div>
        </li>
        <li>
          <div class="card">
            <h3 class="heading">Discussion 3</h3>
            <div class="body">3 posts</div>
          </div>
        </li>
      </ul>
      """

  Scenario: Single level of nesting with extra attributes
    Given a file named "example.dryml" with:
      """
      <collection>
        <heading:>Discussions</heading:>
        <card: class="#{scope.even_odd}"><body:><%= this.posts.length %> posts</body:></card:>
      </collection>
      """
    When the current context is a list of discussions
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <h2 class="heading">Discussions</h2>
      <ul>
        <li>
          <div class="card odd">
            <h3 class="heading">Discussion 1</h3>
            <div class="body">1 posts</div>
          </div>
        </li>
        <li>
          <div class="card even">
            <h3 class="heading">Discussion 2</h3>
            <div class="body">2 posts</div>
          </div>
        </li>
        <li>
          <div class="card odd">
            <h3 class="heading">Discussion 3</h3>
            <div class="body">3 posts</div>
          </div>
        </li>
      </ul>
      """

  Scenario: Multiple levels of nesting
    Given a file named "example.dryml" with:
      """
      <index-page>
        <heading:>Welcome to our forum</heading:>
        <collection:>
          <heading:>Discussions</heading:>
          <card:><body:><%= this.posts.length %> posts</body:></card:>
        </collection:>
      </index-page>
      """
    When the current context is a list of discussions
    And I render "example.dryml"
    Then the output DOM should be:
      """
      <html>
        <head><title>Index Page</title></head>
        <body>
          <h1 class="heading">Welcome to our forum</h1>
          <h2 class="heading">Discussions</h2>
          <ul>
            <li>
              <div class="card">
                <h3 class="heading">Discussion 1</h3>
                <div class="body">1 posts</div>
              </div>
            </li>
            <li>
              <div class="card">
                <h3 class="heading">Discussion 2</h3>
                <div class="body">2 posts</div>
              </div>
            </li>
            <li>
              <div class="card">
                <h3 class="heading">Discussion 3</h3>
                <div class="body">3 posts</div>
              </div>
            </li>
          </ul>
        </body>
      </html>
      """

