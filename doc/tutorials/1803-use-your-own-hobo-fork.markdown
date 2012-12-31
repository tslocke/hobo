# Use your own hobo fork

Originally written by kredmer on 2012-06-23.

If you want to use your own hobo-version and also help fixing problems, there are some easy steps to do this.

**Fork hobo:**

  - you need a [github account]
  - fork [hobo] - see also [fork-a-repo]

>If you have push problems:
>
> - git config -l # to see your config
>  - change git config line to use ssh:

>          remote.origin.url=ssh://git@github.com/YOUR_NAME/hobo.git

**Add this line to your Gemfile:**

       gem "hobo", "=VERSION", :git => 'git://github.com/YOURNAME/hobo.git'
        -> e.g. gem "hobo", "=1.4.0.pre6", :git => 'git://github.com/kredmer/hobo.git'
(and remove your old gem "hobo" line !)

**run in console to update your gemfile.lock:**

       bundle update hobo


**YOU ARE DONE !**


Check issues and send a [pull-request], if you solved a problem.


[github account]: https://github.com/
[hobo]: https://github.com/tablatom/hobo
[fork-a-repo]: https://help.github.com/articles/fork-a-repo
[pull-request]: https://help.github.com/articles/using-pull-requests



