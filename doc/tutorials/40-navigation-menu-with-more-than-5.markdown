# navigation menu with more than 5 items

Originally written by Bryan Larsen on 2010-01-24.

For most applications, one of the first things that is done is to replace the navigation menu with a full custom menu.

However for some applications like admin subsites, the standard navigation would be fine, if it wasn't limited to 5 items.

Put this in your `application.dryml` (or `admin_site.dryml`) for a navigation that isn't limited to 5 items.

    <def tag="main-nav">
      <navigation class="main-nav" merge-attrs param="default">
        <nav-item href="#{base_url}/">Home</nav-item>
        <% models = Hobo::Model.all_models.select { |m| linkable?(m, :index) }.sort_by &:name -%>
        <repeat with="&models">
          <nav-item><ht key="#{this.name.tableize}.nav_item"><%= this.view_hints.model_name_plural %></ht></nav-item>
        </repeat>
      </navigation>
    </def>


