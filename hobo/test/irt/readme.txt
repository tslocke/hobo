In order to run the tests, you need git and irt installed, then run:

    $ rake test:irt

or if you are testing a local repo of hobo, you need to set the:

    $ export HOBODEV=<hobo_repo_root_path>

With HOBODEV set, if you are using rvm, the <hobo_repo_root_path>/.rvmrc file will be duplicated into
the created testapp, so your test will use the same rvm settings.
