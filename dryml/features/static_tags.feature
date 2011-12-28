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

  Scenario: define tags that are used in Rapid
    Given a file named "static_tag.dryml" with:
      """
      <html lang="en">
        <head>
          <link rel="stylesheet" href="foo" />
        </head>
        <body>
          <header>
            <a href="something" target="_blank">Link text</a>
          </header>
          <section class="content">
            <table width="100%">
              <tr>
                <td>FOO</td>
                <td>BAR</td>
              </tr>
            </table>
          </section>
          <footer>
            <form action="wut">
              <input type="text" name="some_field" />
              <submit value="Submit" />
            </form>
          </footer>
        </body>
      </html>
      """
    When I render "static_tag.dryml"
    Then the output DOM should be:
      """
      <html lang="en">
        <head>
          <link rel="stylesheet" href="foo" />
        </head>
        <body>
          <header>
            <a href="something" target="_blank">Link text</a>
          </header>
          <section class="content">
            <table width="100%">
              <tr>
                <td>FOO</td>
                <td>BAR</td>
              </tr>
            </table>
          </section>
          <footer>
            <form action="wut">
              <input type="text" name="some_field" />
              <submit value="Submit" />
            </form>
          </footer>
        </body>
      </html>
      """
