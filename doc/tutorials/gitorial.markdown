


<a name='gitorial-sidebar'> </a>


Gitorial Sidebar
{: .document-title}

Contents
{: .contents-heading}

- contents
{:toc}

# Gitorial Sidebar

The agility tutorial is a 'gitorial', a tutorial made with
[git](http://www.git-scm.org/).

## Using patch

The patches we have displayed are simplified for on-screen viewing.
However, there is a link beside each entry you can click on to
download the raw patch.  To apply the raw patch from your project's
root directory:

    patch -p1 < patch-file

## Using git fully

Following along using git allows you to quickly and easily skip
through the tutorial.   Doing so requires a little bit of git
knowledge -- you may not wish to learn git and Hobo simultaneously.

Check out the [application from
github](http://github.com/Hobo/agility-gitorial/tree/master):

    $ git clone git://github.com/Hobo/agility-gitorial.git
    $ cd agility-gitorial

Now rewind the tutorial to the beginning, and create your own branch
to record your changes.

    $ git checkout gitorial-004
    $ git checkout -b my_branch

You'll notice that the first command gives you a warning, recommending
that you also run the second command.  You should also notice that
we're starting at step four -- this includes the ".gitignore" file and
the initial run of the hobo command.

Start the tutorial, and follow along.

Every once in a while, check in your progress:

    $ git add .
    $ git commit

After checking in your progress, you can merge in the changes from the
gitorial to see if you typed everything in correctly or not.  For
example, if the first time you checked in your progress is at step
gitorial-020:

    $ git merge gitorial-020

It's quite likely there are conflicts -- you didn't follow the
tutorial exactly.  For instance, if your `tasks_controller.rb` is
different, you'll see a message like:

    CONFLICT (content): Merge conflict in app/controllers/tasks_controller.rb
    Automatic merge failed; fix conflicts and then commit the result.

Edit `tasks_controller.rb` to fix the conflict, and then resolve the
conflict:

    $ git add app/controllers/tasks_controller.rb
    $ git commit

Once you have your current position merged in cleanly, you can skip
ahead to any point in the tutorial:

    $ git merge gitorial-060

You can only jump forwards.  To jump backwards, utilize a different
mechanism, such as `git checkout` or `Stacked Git`.

## Using git checkout

This mechanism is the quickest way to jump around in the tutorial.
However, any changes you make will be lost.

    $ git clone git://github.com/Hobo/agility-gitorial.git
    $ cd agility-gitorial
    $ git submodule update --init

Then you can switch to any point in the tutorial:

    $ git checkout gitorial-001

## Using stacked git

We used [Stacked Git](http://www.procode.org/stgit/) to develop this
gitorial.  It's a great tool to follow this gitorial.

Instructions for using stacked git with this gitorial are in the
README in our [source
repository](http://github.com/Hobo/agility-gitorial-patches/tree/master).

# Updating to later versions of the tutorial

To keep the gitorial clean, updates to the gitorial **rewrite
history**.  That means that you cannot `git pull`.  If you wish to
update to a later version of the tutorial, you must `git clone` the
repository again and manually move any changes you have made from your
old clone to the new one.


gitorial-002: [view on github](http://github.com/Hobo/agility-gitorial/commit/ec14ee2939346e0be5d36ad866c8b2f89ff7796b), [download 02-gitorial-sidebar.patch](/patches/agility/02-gitorial-sidebar.patch)
{: .commit}
