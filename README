The README for hobo is in hobo/README.

However, you're probably more interested in hobo/CHANGES-1.4.txt or
http://cookbook.hobocentral.net

### Unit tests

    export HOBODEV=`pwd`
    for f in dryml hobo_support hobo_fields hobo ; do cd $f ; bundle install ; cd .. ; done
    rake test

### Integration tests

see README in integration_tests/agility

### Smoke test

This test is not super important. It's important that this test be run
just before gems are released, but we won't see much benefit if people
other than the maintainer run this test.

Prerequisites:  RVM, wget.   Creates and uses the hobo-smoke rvm gemset.

    unset HOBODEV
    export HOBODEV
    cd integration_tests
    ./smoke_test.sh