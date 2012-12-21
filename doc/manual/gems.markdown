The Hobo Gem Stack and UI Plugins
{.document-title}

Hobo 2.0 includes several different Gems.   This manual chapter provides a summary of the capabilities and requirements of each of these.

Contents
{.contents-heading}

- contents
{:toc}

# Summary

A Hobo 2.0 application will always include the `hobo_support`, `dryml`, `hobo_fields`, `hobo`, `hobo_rapid` and `hobo_jquery` gems.  It will also include one theme; `hobo_bootstrap` and `hobo_clean` are the two most popular themes.  It will also include one or both of `hobo_jquery_ui` or `hobo_bootstrap_ui`.  All other `hobo_*` gems are optional and are not included by the generator.

# Base Gems

Hobo depends on the following three gems:

[**Hobo Support**](/manual/hobo_support) is akin to
[Active Support](http://as.rubyonrails.org/) in that it provides a grab bag of
utility classes and extensions that should be useful to all Ruby
projects, not just Ruby on Rails projects.

[**Hobo Fields**](/manual/hobo_fields) is an extension to
[Active Record](http://ar.rubyonrails.org/) that allows you to add
rich types to Active Record and automatically create migrations.

[**DRYML**](/manual/dryml-guide) is a template language that allows you to
create highly reusable HTML components.

The Hobo gem proper provides most of the rest of Hobo, including all
of the models, controllers and generators, along with some of the view
helpers and plumbing.  Parts of Hobo should be pulled out into their
own gem, but this has not yet occured.

[**Hobo Rapid**](/api_plugins/hobo_rapid) is the standard tag library for Hobo, and as such is a required component.

[**Hobo jQuery**](/api_plugins/hobo_jquery) provides the Javascript for [Hobo Rapid](/api_plugins/hobo_rapid) and for [Hobo part AJAX](http://cookbook.hobocentral.net/manual/ajax).  The interface that hobo_jquery uses is well-defined and described in [TBD] so it is theoretically possible to replace hobo_jquery with a plugin based on something other than jQuery.

# Themes

A Hobo application also requires a theme.   The default theme for Hobo 2.0 is [**Hobo Bootstrap**](/api_plugins/hobo_bootstrap), which uses [Bootstrap 2.X](http://twitter.github.com/bootstrap/).

Each subsite in your application may use a different theme.

[**Hobo Clean**](/api_plugins/hobo_clean) was the default theme for Hobo 0.8 through 1.3 and is still available.   You can also choose to use its variant, [Hobo Clean Sidemenu](/api_plugins/hobo_clean_sidemenu).

It's not difficult to [create your own theme](http://cookbook.hobocentral.net/manual/plugins#themes).

# UI Plugin

Hobo also requires a few UI widgets and capabilities that aren't provided by jQuery itself.   These can be provided by [**Hobo jQuery-UI**](/api_plugins/hobo_jquery_ui) and/or [**Hobo Bootstrap UI**](/api_plugins/hobo_bootstrap_ui).

## Valid combinations

You must include either `hobo_jquery_ui` or `hobo_bootstrap_ui` or both.   `hobo_jquery_ui` depends on `hobo_jquery` and `jQuery-UI`.   `hobo_bootstrap_ui` depends on `hobo_jquery` and `hobo_bootstrap`.  `hobo_bootstrap_ui` cannot be used with alternate themes, such as `hobo_clean`.

If you are using `hobo_bootstrap_ui` without `hobo_jquery_ui` you may also remove `jQuery-UI` from your system, but you will lose effects and spinner positioning.

### Defaults

As of Hobo 2.0.0.pre8, a default invocation of the Hobo generator includes all three items, with `hobo_bootstrap_ui` loaded after `hobo_jquery_ui` so that `hobo_bootstrap_ui` is preferred when there is overlap.

If a theme other than `hobo_bootstrap` is chosen, `hobo_bootstrap_ui` is not included in the application but `hobo_jquery_ui` is.

`jQuery-UI` is always included by the Hobo generator.

## Essential tags

Hobo requires three tags that are provided by both `hobo_jquery_ui` and `hobo_bootstrap_ui`:  `<search-results-container>`, `<name-one>`, and `<input for="Date">`.

If you are using both plugins, the plugin loaded last will provide these three tags.   These tags are just aliases, though: the underlying implementations will still be available.

`hobo_jquery_ui` uses `<dialog-box>`, `<name-one-jquery-ui>` and `<datepicker>` for the implementation of the essential tags.

`hobo_bootstrap_ui` uses `<modal>`, `<name-one-bootstrap>` and `<bootstrap-datepicker>` for the implementation of the essential tags.

`hobo_rapid` provides `<datepicker-rails>` which requires neither jQuery nor Bootstrap.

## acts-as-list tags

`hobo_jquery_ui` provides `<sortable-collection>` and `<sortable-input-many>`, which do not have equivalents in `hobo_bootstrap_ui`.  These tags are used by Hobo if you add the `acts_as_list` plugin to a hobo model.

## Other tags

Both plugins provide other tags that you can use in your application, but which aren't ever used automatically by Hobo.

`hobo_jquery_ui` provides `<accordion>`, `<tabs>`, `<toggle>`, `<combobox>` and others.

`hobo_bootstrap_ui` contains fewer tags, although that is likely to grow in the future.

Consult the [documentation](http://cookbook.hobocentral.net/api_plugins) for a full listing.

## Effects

If you do not use `hobo_jquery_ui` in your application, then jQuery-UI itself becomes optional.  If you remove jQuery-UI you also lose the ability to use [effects](http://cookbook.hobocentral.net/manual/ajax#effects) with part AJAX as well as the ability to position the AJAX [spinner](http://cookbook.hobocentral.net/manual/ajax#spinner)

## Removing `hobo_jquery_ui`

To remove `hobo_jquery_ui` from your application, remove references to it in `Gemfile`, `app/assets/javascripts/*.js`, `app/assets/stylesheets/*.js` and `app/views/taglibs/*_site.dryml`, and then run `bundle install`.

## Removing jQuery-UI

After `hobo_jquery_ui` is removed, you may remove jQuery-UI from your system by removing references to it in `app/assets/javascripts/application.js` and `app/assets/stylesheets/*.[s]css`.

# Optional Plugins

All other plugins listed on the [plugin page](/api_plugins) are optional, providing additional capabilities to your application.