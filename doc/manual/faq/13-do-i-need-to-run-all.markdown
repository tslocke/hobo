# Do I need to run all of the generators?

Originally written by Peeja on 2008-10-18.

Do I need to run all of the generators when I use edge Hobo?

    $ ruby script/generate hobo --add-routes
    $ ruby script/generate hobo_rapid --import-tags
    $ ruby script/generate hobo_user_model user
    $ ruby script/generate hobo_user_controller user
    $ ruby script/generate hobo_front_controller front --delete-index --add-routes

Does Hobo require all of these to function?  Or can I leave some out if they don't make sense in my app?