#!/bin/bash

gems=`rake gems[build,force] | grep File: | cut -f 4 -d ' '`
full_gems=`for f in $gems ; do find . -name $f ; done`
source rvm gemset create hobo-smoke
source rvm gemset use hobo-smoke
source rvm --force gemset empty hobo-smoke
source rvm gemset use hobo-smoke

gem install --no-rdoc --no-ri $full_gems

rm -rf smoke
hobo new smoke --skip-setup  # will do a bundle install
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

wget http://localhost:3003/
grep "Things" index.html
grep "Smoke" index.html
grep "Congratulations" index.html

cd ..
rm -rf smoke

kill $pid || true
sleep 1
kill -9 $pid || true
echo SUCCESS
