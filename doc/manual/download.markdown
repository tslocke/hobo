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
do not already have them installed.  The two Hobo prerequisites may be
used independently without Hobo, so you may wish to install either or
all of them instead of Hobo.

    gem install hobo_support
    gem install hobo_fields
    gem install dryml

If you wish to download the gems directly, you can get them from
[RubyGems.org](http://rubygems.org).  There are four gems:
[hobo_support](http://rubygems.org/gems/hobo_support),
[hobo_fields](http://rubygems.org/gems/hobo_fields),
[dryml](http://rubygems.org/gems/dryml) and
[hobo](http://rubygems.org/gems/hobo)

The source code for Hobo is available on
[github:tablatom/hobo](http://github.com/tablatom/hobo)
