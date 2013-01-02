Hobo Manual
{.document-title}

Welcome to Hobo, we're sure you'll enjoy the ride.

## Introduction

First you need to [**Download and Install**](/manual/download) Hobo.

Next you will probably want to check out one of our fine
[**tutorials**](/tutorials).

## Ruby

[**Hobo Support**](/manual/hobo_support) is akin to
[Active Support](http://as.rubyonrails.org/) in that it provides a grab bag of
utility classes and extensions that should be useful to all Ruby
projects, not just Ruby on Rails projects.

## Active Record

[**Hobo Fields**](/manual/hobo_fields) is an extension to
[Active Record](http://ar.rubyonrails.org/) that allows you to add
rich types to Active Record and automatically create migrations.

[**Hobo Scopes**](/manual/scopes) are an extension to the *named scope*
and *dynamic finder* functionality in
[Active Record](http://ar.rubyonrails.org/).

[**The Hobo Permission system**](/manual/permissions) is an extension to
[Active Record](http://ar.rubyonrails.org/) that allows you define
which actions on your model are permitted by which users.

[**Accessible Associations**](/manual/multi_model_forms) is an
[Active Record](http://ar.rubyonrails.org/) extension that allows
nested models in forms.

[**Users and Authentication**](/manual/users_and_authentication)
documents the Hobo user model: how to use it, what it provides and how
to use Hobo without it.

[**Miscellaneous Model Extensions**](/manual/model) document the rest of
Hobo's extensions to [Active Record](http://ar.rubyonrails.org/).

## Action Controller and Routing

[**Controllers and Routing**](/manual/controllers) documents Hobo's
extensions to
[Action Controller](http://api.rubyonrails.org/classes/ActionController/Base.html)

[**Miscellaneous Controller Extensions**](/manual/controller) document the rest of
Hobo's extensions to [Action Controller](http://api.rubyonrails.org/classes/ActionController/Base.html).

## Action View

[**DRYML**](/manual/dryml-guide) is a template language that allows you to
create highly reusable HTML components.

[**Rapid**](/api_plugins/hobo_rapid) is a large library of HTML tags built with
[DRYML](/manual/dryml-guide).

[**Ajax**](/manual/ajax) describes how Rapid and Hobo combine to support
[Ajax](http://en.wikipedia.org/wiki/Ajax_%28programming%29) in a
fashion that's often easier than using Web 1.0 techniques.

## Tags & Javascript

[**Hobo Rapid**](/api_plugins/hobo_rapid) is the standard tag library for Hobo, and as such is a required component.

[**Hobo jQuery**](/api_plugins/hobo_jquery) provides the Javascript for [Hobo Rapid](/api_plugins/hobo_rapid) and for [Hobo part AJAX](http://cookbook.hobocentral.net/manual/ajax).  The interface that hobo_jquery uses is well-defined and described in TBD so it is theoretically possible to replace hobo_jquery with a plugin based on something other than jQuery.

## Themes

A Hobo application also requires a theme.   The default theme for Hobo 2.0 is [**Hobo Bootstrap**](/api_plugins/hobo_bootstrap), which uses [Bootstrap 2.X](http://twitter.github.com/bootstrap/).

Each subsite in your application may use a different theme.

[**Hobo Clean**](/api_plugins/hobo_clean) was the default theme for Hobo 0.8 through 1.3 and is still available.   You can also choose to use its variant, [Hobo Clean Sidemenu](/api_plugins/hobo_clean_sidemenu).

It's not difficult to [create your own theme](http://cookbook.hobocentral.net/manual/plugins#themes).

## UI Plugin

Hobo also requires a few UI widgets and capabilities that aren't provided by jQuery itself.   These can be provided by [**Hobo jQuery-UI**](/api_plugins/hobo_jquery_ui) and/or [**Hobo Bootstrap UI**](/api_plugins/hobo_bootstrap_ui).

More information about the differences and overlap between these two are explained by [UI Plugins](/manual/gems)

## Top to Bottom

[**Lifecycles**](/manual/lifecycles) lets you define a state machine in
your [Active Record](http://ar.rubyonrails.org/) model which
automatically create appropriate actions for your controller and views.

[**View Hints**](/manual/viewhints) allow you to annotate your model with
information relevant to automatic view generation.

[**Generators**](/manual/generators) documents the generators that Hobo
allows you to access via `script/generate`.

Hobo allows you to [**Internationalize**](/manual/i18n) your program to
support multiple languages.

Once you've created useful tags for your own application, how about turning them into a [**plugin**](/manual/plugins) and sharing them with the world?
