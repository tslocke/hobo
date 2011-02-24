#!/usr/bin/env bash
set -e

cd `dirname $0`
for gemsetd in gemsets/* ; do
    echo "*****************************************************"
    echo `basename $gemsetd`
    source rvm use `basename $gemsetd`
    for bundled in $gemsetd/* ; do
        echo "============================================================"
        echo `basename $bundled`
        (
            cd .. ;
            ln -sf test_scripts/$bundled/Gemfile . ;
            ln -sf test_scripts/$bundled/Gemfile.lock . ;
            bundle exec rake test_all
        )
    done
done

( cd .. ; rm -f Gemfile Gemfile.lock )

echo "TESTS SUCCESSFUL."
