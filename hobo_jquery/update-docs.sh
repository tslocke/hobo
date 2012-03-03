#!/bin/sh

# make sure to do a git commit before running so you don't get bogus commit messages

set -e
set -x

cd lib
ruby doc.rb
cd ..
git checkout gh-pages
cp documentation/doc.html documentation.html
git add documentation.html
git commit -m "doc update"
git push origin gh-pages
git checkout master
