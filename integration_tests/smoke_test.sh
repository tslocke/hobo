#!/bin/bash

source "$HOME/.rvm/scripts/rvm" 

unset HOBODEV

my_dir=`pwd`

cd ..
gems=`rake gems[build,force] | grep File: | cut -f 4 -d ' '`
cd integration_tests
full_gems=`for f in $gems ; do find .. -name $f ; done`

rvm gemset create hobo-smoke
rvm gemset use hobo-smoke
rvm --force gemset empty hobo-smoke
rvm gemset use hobo-smoke

gem install --no-rdoc --no-ri $full_gems

cd ../../hobo_bootstrap
gem install --no-rdoc --no-ri `gem build hobo_bootstrap.gemspec | grep File: | cut -f 4 -d ' '`
cd ../hobo_bootstrap_ui
gem install --no-rdoc --no-ri `gem build hobo_bootstrap_ui.gemspec | grep File: | cut -f 4 -d ' '`

cd $my_dir

# invite only
rm -rf smoke
hobo new smoke --setup --invite-only
cd smoke

rails s -p 3003 &
pid=$!
sleep 45

set -e

wget http://localhost:3003/
grep "Smoke" index.html
grep "Congratulations" index.html

wget http://localhost:3003/admin/users
grep "No records to display" users
grep 'Users : Smoke - Admin' users
grep "New User" users

set +e

cd ..

kill $pid || true
sleep 1
kill -9 $pid || true
echo SUCCESS

# simple setup
rm -rf smoke
hobo new smoke --setup
cd smoke

rails g hobo:resource thing name:string body:text
echo "m" > response.txt
echo "" >> response.txt
rails g hobo:migration < response.txt

rails s -p 3003 &
pid=$!
sleep 45

set -e

wget http://localhost:3003/
grep "Things" index.html
grep "Smoke" index.html
grep "Congratulations" index.html

set +e

kill $pid || true
sleep 1
kill -9 $pid || true
echo SUCCESS

cd ..

# clean theme
rm -rf smoke
hobo new smoke --setup --front-theme=clean
cd smoke

rails g hobo:resource thing name:string body:text
echo "m" > response.txt
echo "" >> response.txt
rails g hobo:migration < response.txt

rails s -p 3003 &
pid=$!
sleep 45

set -e

wget http://localhost:3003/
grep "Things" index.html
grep "Smoke" index.html
grep "Congratulations" index.html

set +e

kill $pid || true
sleep 1
kill -9 $pid || true
echo SUCCESS

cd ..

# admin subsite
rm -rf smoke
hobo new smoke --setup --add-admin-subsite
cd smoke

rails s -p 3003 &
pid=$!
sleep 45

set -e

wget http://localhost:3003/
grep "Smoke" index.html
grep "Congratulations" index.html

wget http://localhost:3003/admin/users
grep "No records to display" users
grep 'Users : Smoke - Admin' users
grep "New User" users

set +e

kill $pid || true
sleep 1
kill -9 $pid || true
echo SUCCESS

cd ..

rm -rf smoke

