#!/bin/sh

# make sure to do a git commit before running so you don't get bogus commit messages

set -e
set -x

( cd ../hobo-jquery-makedoc ; rake generate_all )
( cd ../hobo-jquery-gh-pages ;
  git commit -a -m "doc update" || true; 
  git push origin gh-pages)
