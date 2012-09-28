Creating Hobo Plugins
{.document-title}

All of Hobo's tags are provided via plugins.  It's quite easy to
create plugins so that others can reuse any tags that you've created.

Contents
{.contents-heading}

- contents
{:toc}

# The Plugin Generator

You can create the skeleton for your plugin by typing

    hobo plugin my_plugin

This creates a skeleton Rails plugin and then modifies it into a Hobo plugin.

# Adding to an Application

Once you've Add the local version of your plugin to an application by typing

    rails generate hobo:install_plugin my_plugin /path/to/my_plugin

If your plugin is designed to be a theme, type this instead:

    rails generate hobo:install_plugin my_plugin /path/to/my_plugin --subsite==front --css-top

# Plugin Files

The first thing I do when creating a plugin is to remove files that I don't need.  It's easy to regenerate them by creating a new plugin skeleton, so they're just taking up space.  I recommend removing

    test         # a bare Rails application
    Gemfile      # used by test app
    Gemfile.lock # used by test app
    Rakefile     # rake tasks
    lib/tasks    # rake tasks
    app          # contains app/helpers/my_plugin_helper.rb

## README.markdown

The first section of this file will become the "summary" of your plugin in the cookbook, and the entire file will be included as the full description of the plugin.

## taglibs/my_plugin.dryml

Place any tag definitions for your plugin in this file.   If you have more than a couple of tag definitions, I recommend simply using separate files for each tag definition and use taglibs/my_plugin.dryml to include those other files.

Remember that the comment before each tag definition will become documentation for the tag in the cookbook.

If your plugin is very large, you can use subdirectories.   See hobo_rapid as an example of this maps to the cookbook.

## vendor/assets

This directory will contain the javascripts, stylesheets and images required by your plugin.

## app/helpers/my_plugin_helper.rb

This file can contain any view helpers you create for your plugin.

## app/rich_types/

Rich type definitions can be placed in this directory

## app/controllers and app/models

Controllers and models can also be added to Hobo plugins here, although this is rare.

## my_plugin.gemspec

Please ensure that you modify this file to include the plugin description and your name.

## lib/my_plugin.rb

There's a variable in here `EDIT_LINK_BASE` that is used by the
cookbook to generate the "Edit this file" links. Please update it to
point to your github for the plugin.

## lib/my_plugin/railtie.rb

This file is required but should not need modifications.

## lib/my_plugin/version.rb

You can bump the version number of your plugin by editing this file

# Creating a Hobo Plugin From a jQuery Plugin

It isn't difficult to use a jQuery widget from within a Hobo
application using standard HTML and Javascript techniques.   For our
example, we'll use https://github.com/recurser/jquery-simple-color.

Here's an example using just HTML-style DRYML and Javascript:

    <edit-page>
      <custom-scripts:>
        <javascript name="jquery.simple-color"/>
        <script type="text/javascript">
          jQuery(document).ready(function($) {
            $('.simple_color').simpleColor();
          });
        </script>
      </custom-scripts:>

      <form:>
        <field-list:>
          <color-view:>
            <input class='simple_color'/>
          </color-view:>
        </field-list:>
      </form:>
    </edit-page>

That's fine, and if you're only using it once and in one place, it's
OK to stop there.  However, we can make it better and turn this into a
Hobo plugin so that the color picker is used automatically without any
intervention required.  Even better, other users can take advantage,
too.

Generate a new plugin

    hobo plugin simple_color

And then copy jquery.simple-color.js into vendor/assets/javascripts

Let's start with the bare minimum hobo plugin.   It consists of
two parts.   Here's the tag definition:

    <def tag="simple-color">
      <input data-rapid="#{data_rapid('simple-color')}" merge/>
    </def>

And here's the javascript:

    $.fn.hjq_simple_color = function(annotations) {
      this.simpleColor(annotations);
    };

There's code in hjq.js that notices the data-rapid attribute, and then
tries to call a jQuery plugin with the same name with `hjq_`
prepended.

That javascript is actually a full jQuery plugin that calls out to the
Simple Color plugin. There are lots of resources on the web
documenting how to create jQuery plugins if you need something more
extensive, and there are lots of examples in the hobo_jquery gem. Many
of them are almost as simple as the above snippet of javascript.

The next step is to allow users to customize the color picker.   Let's
add support for the displayColorCode option:

    <def tag="simple-color" attrs="displayColorCode" >
      <input data-rapid="#{data_rapid('simple-color', :displayColorCode => displayColorCode)}" merge/>
    </def>

However, simple-color has 14 available options, so it could get
cumbersome to support them all that way.  There's an easier way:

    <def tag="simple-color">
      <% options, attrs = attributes.partition_hash(['defaultColor', 'border', 'cellWidth', 'cellHeight', 'cellMargin', 'boxWidth', 'boxHeight', 'columns', 'insert', 'buttonClass', 'colors', 'displayColorCode', 'colorCodeAlign', 'colorCodeColor']) %>
      <input data-rapid="#{data_rapid('simple-color', options)}" merge-attrs="&attrs"/>
    </def>

That's good enough for simple-color, because all of its options are
data types. However, many jQuery plugins support passing javascript
functions for option values. Obviously that's a little bit more work,
but not much. Here's an example of that:

    <def tag="my-plugin">
      <% options, attrs = attributes.partition_hash(['foo', 'bar'])
         events, html_attrs = attrs.partition_hash(['myMethod']) %>
      <div data-rapid="#{data_rapid('my-plugin', :options => options, :events => events)}" merge-attrs="&html_attrs"/>
    </def>

    $.fn.hjq_my_plugin = function(annotations) {
      this.myPlugin(this.hjq('getOptions', annotations)));
    };

We now have a working simple-color tag.  However, it still has to be
called explicitly every time we need it.  We can make it even more
awesome by taking advantage of Hobo's rich types.

Create app/rich_types/color.rb:

     class Color < String
       COLUMN_TYPE = :string
       HoboFields.register_type(:color, self)
     end

Now in your fields definition, use your new rich type rather than `:string`:

    fields do
      color Color, :default => "#000000"
    end

Now we can define an input for our new type:

    <def tag="input" for="Color">
      <simple-color merge/>
    </def>

But that blows up into an infinite loop.  The input tag references the
simple-color tag which references the input tag which references the
simple-color tag which...

The solution here is to bypass the input tag by using Rails' text_field_tag:

    <def tag="simple-color" attrs="name"><%=
      options, attrs = attributes.partition_hash(['defaultColor', 'border', 'cellWidth', 'cellHeight', 'cellMargin', 'boxWidth', 'boxHeight', 'columns', 'insert', 'buttonClass', 'colors', 'displayColorCode', 'colorCodeAlign', 'colorCodeColor'])
      add_data_rapid!(attrs, 'simple-color', options)
      text_field_tag(name, this, deunderscore_attributes(attrs))
    %></def>

For completion, let's define a view for our new rich type:

    <def tag="view" for="Color">
      <span style="background-color: #{html_escape(this)};"><%= this %></span>
    </def>

And we're done!   The full source for this plugin can be found [on github](https://github.com/Hobo/hobo_simple_color)

# Themes

A hobo theme is simply a Hobo plugin that defines the "page" tag.

(FIXME: more here would be nice)

# Submitting Your Plugin

Push your plugin to github, and then email the hobo-users mailing list
announcing your plugin. If it's properly documented, I will add it to
the Hobo Cookbook. Proper documentation consists of a README.markdown
formatted as described above, as well as documentation in a comment
before relevant tags in your DRYML.

You can also push your gem to rubygems.org. First create an account on
rubygems.org and then run

     curl -u my_user_name_on_rubygems https://rubygems.org/api/v1/api_key.yaml >
~/.gem/credentials

Then you can build and push your gem:

     gem build my_plugin.gemspec
     gem push my_plugin-0.0.1.gem

After you push your gem be sure and increment your version number in version.rb.
