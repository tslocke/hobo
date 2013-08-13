Downloading and Installing Hobo
{.document-title}

Before installing Hobo, you must have
[Ruby](http://www.ruby-lang.org/en/),
[RubyGems](http://docs.rubygems.org/) and [Ruby on
Rails](http://rubyonrails.org/) installed.

The standard mechanism for installing Hobo is to use gem:

    gem install hobo

This command will also install the Hobo prerequisites [Hobo
Support](/manual/hobo_support), [Hobo Fields](/manual/hobo_fields) and
[Dryml](/manual/dryml) as well as [Mislav's
will_paginate](http://wiki.github.com/mislav/will_paginate/), if you
do not already have them installed.  The three Hobo prerequisites may be
used independently without Hobo, so you may wish to install either or
all of them instead of Hobo.

There are additional gems that are almost always used with Hobo.  The Hobo generator will install these gems automatically, but for reference, a full Hobo application will include [Hobo Rapid](/api_plugins/hobo_rapid) and [Hobo jQuery](/api_plugins/hobo_jquery).   The generator will also let you pick a theme.   There are currently two major themes available:  [Hobo Bootstrap](/api_plugins/hobo_bootstrap) and [Hobo Clean](/api_plugins/hobo_clean).  There are two minor variants of theme:  [Hobo Clean Sidemenu](/api_plugins/hobo_clean_sidemenu) and [Hobo Clean Admin](/api_plugins/hobo_clean_admin).   The generator will also install one or both of the toolkits: [Hobo jQuery-UI](/api_plugins/hobo_jquery_ui) and/or [Hobo Bootstrap-UI](/api_plugins/hobo_bootstrap_ui).   The toolkits are nominally optionally, but recommended.


If you wish to download the gems directly, you can get them from
[RubyGems.org](http://rubygems.org).

The source code for Hobo is available at [github:Hobo/hobo](http://github.com/Hobo/hobo) and additional sources are available in the [github Hobo organization](https://github.com/Hobo)
