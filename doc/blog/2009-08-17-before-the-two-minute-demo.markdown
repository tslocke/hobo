--- 
wordpress_id: 252
author_login: bryanlarsen
layout: page
comments: []

author: Bryan Larsen
title: Before the two-minute demo
published: true
tags: []

date: 2009-08-17 16:36:55 +00:00
categories: 
- General
author_email: bryan@larsen.st
wordpress_url: http://hobocentral.net/blog/?page_id=252
author_url: http://bryan.larsen.st
status: publish
---
To get a virgin test environment, I installed a copy of Ubuntu 9.04 (Jaunty Jackolope) inside a virtual machine.&nbsp; Here are the steps I followed before I was able to try the [Hobo two minute demo](http://cookbook.hobocentral.net/tutorials/two-minutes)

These are essentially the instructions on how to install Rails in Ubuntu.  There are thousands of these posts on blogs over the internet.   I repeat them here for anybody who is new to Rails or Ubuntu and wants to give Hobo a try.

First I updated Ubuntu:

    sudo apt-get update
    sudo apt-get dist-upgrade

Then I installed ruby, sqlite, git and subversion:  (git and subversion are optional).

    sudo apt-get install build-essential ruby-full sqlite3 libsqlite3-ruby1.8 git-core subversion

You also need gem.  There are two choices:  use Ubuntu's gem or build from source.  Gem breaks Linux standard practice in several different ways, so Ubuntu's version of gem has a few oddities.  Most people install the standard version of gem instead by building it from source.

    wget http://rubyforge.org/frs/download.php/60718/rubygems-1.3.5.tgz
    tar xvzf rubygems-1.3.5.tgz
    cd rubygems-1.3.5
    sudo ruby setup.rb
    cd /usr/bin
    sudo ln -s gem1.8 gem

Then we install rails:

    sudo gem install rails

Now you should be able to move on to the [two minute Hobo demonstration](http://cookbook.hobocentral.net/tutorials/two-minutes)
