# Upgrade an app to the latest version of Hobo

Originally written by Tom on 2008-10-17.

This recipe answers [How to safely upgrade to a new hobo version](/questions/11-how-to-safely-upgrade-to-a)

## Breaking Changes

It's quite common that there are breaking changes from one version of Hobo to the next. These will settle down once we get to 1.0. In the meantime, there are no general instructions for fixing your app. Have a look at the changelog, any announcements on the blog, or ask in the user group.

## Upgrading

Upgrading Hobo is a simple matter of

    $ gem update hobo

Or, if you are tracking edge Hobo using git

    $ cd vendor/plugins/hobo
    $ git pull

You should also re-run the `hobo_rapid` generator, as some of the assets put in `public` by that generator may well have changed.

    $ ruby script/generate hobo_rapid

For minor upgrades to Hobo that should be enough. Head over to the user group if your app is still not working.

