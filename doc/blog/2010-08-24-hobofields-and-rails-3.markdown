--- 
wordpress_id: 320
author_login: admin
layout: post
comments: 
- author: Matt Jones
  date: Wed Aug 25 00:37:28 +0000 2010
  id: 52009
  content: |
    <p>Note to readers: the git url above should be git://github.com/tablatom/hobo.git</p>
    
    <p>I'd edit it inline, but Wordpress seems dead-set on b0rking every code tag when loading the post into the editor...</p>

  date_gmt: Wed Aug 25 00:37:28 +0000 2010
  author_email: al2o3cr@gmail.com
  author_url: ""
- author: Owen
  date: Wed Aug 25 02:19:40 +0000 2010
  id: 52010
  content: |
    <p>Thanks, Matt, for your help on this:</p>
    
    <blockquote>
      <p>git clone git://github.com/tablatom/hobo.git
      cd hobo
      git checkout -b rails3 origin/rails3</p>
    </blockquote>

  date_gmt: Wed Aug 25 02:19:40 +0000 2010
  author_email: ""
  author_url: ""
- author: Tom
  date: Wed Aug 25 07:27:10 +0000 2010
  id: 52011
  content: |
    <p>Thanks Owen &amp; Matt - now fixed!</p>

  date_gmt: Wed Aug 25 07:27:10 +0000 2010
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Owen
  date: Thu Aug 26 21:06:29 +0000 2010
  id: 52012
  content: |
    <p>Just ran with the new pre2 version (August 26) and got my first Rails 3 migration to work.</p>
    
    <p>Thanks Domizio!</p>
    
    <p>-Owen</p>

  date_gmt: Thu Aug 26 21:06:29 +0000 2010
  author_email: ""
  author_url: ""
- author: Don Ziesig
  date: Thu Sep 16 14:36:35 +0000 2010
  id: 52021
  content: |
    <p>You all seem to have jeweler installed.  For those of us just getting started, please add "sudo gem install jeweler" to the instructions.</p>

  date_gmt: Thu Sep 16 14:36:35 +0000 2010
  author_email: donald@ziesig.org
  author_url: http://www.z-house.info
- author: Tom
  date: Fri Sep 17 12:35:40 +0000 2010
  id: 52022
  content: |
    <p>Don - Thanks, I've added that extra step. The problem with having an already set-up environment, is that you loose track of what you did : )</p>

  date_gmt: Fri Sep 17 12:35:40 +0000 2010
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Javier
  date: Tue Sep 21 02:04:23 +0000 2010
  id: 52024
  content: |
    <p>rails &amp; hobo newbbie. I've checked out today the rails3 branch.. it is not working yet, right ? I get "router.rb:91: syntax error, unexpected tSTRING<em>BEG, expecting keyword</em>do or '{' or '(' (SyntaxError)" when trying to run "rails s" on a new hobo app</p>

  date_gmt: Tue Sep 21 02:04:23 +0000 2010
  author_email: javier.alejandro.castro@gmail.com
  author_url: ""
- author: Tiago Franco
  date: Tue Sep 28 22:46:18 +0000 2010
  id: 52029
  content: |
    <p>Do I need to set this up on a Hobo Rails3 app?</p>
    
    <p>Thanks.</p>

  date_gmt: Tue Sep 28 22:46:18 +0000 2010
  author_email: ""
  author_url: http://imaginarycloud.com
author: Tom
title: HoboFields and Rails 3
excerpt: |
  **Update:** I should of known better than to post this late at night. Now improved with actual working instructions!
  
  Folks, thanks to Domizio's great work, HoboFields is ready to try out with Rails 3. Here's a quick guide to getting it installed and running the migration generator. You'll need git to grab the latest code, as nothing has been released as a gem, but apart from that you won't have to do anything too technical. Please note, Rails 3 RC2 just dropped today, but right now we're still on RC1, so please make sure you have that version of Rails installed if you want to try this out.
  

published: true
tags: []

date: 2010-08-24 21:58:58 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/?p=320
author_url: http://www.hobocentral.net
status: publish
---
**Update:** I should of known better than to post this late at night. Now improved with actual working instructions!

Folks, thanks to Domizio's great work, HoboFields is ready to try out with Rails 3. Here's a quick guide to getting it installed and running the migration generator. You'll need git to grab the latest code, as nothing has been released as a gem, but apart from that you won't have to do anything too technical. Please note, Rails 3 RC2 just dropped today, but right now we're still on RC1, so please make sure you have that version of Rails installed if you want to try this out.

<a id="more"></a><a id="more-320"></a>

OK, let's grab the code:

    git clone http://github.com/tablatom/hobo.git

The Rails 3 work is happening on the cunningly named `rails3` branch, so you now need to

    cd hobo
    git checkout origin/rails3

Next, we use Rake to generate and install the gems for HoboSupport and HoboFields. Note that this step requires the `jeweler` gem, so you have first have to:

    gem install jeweler

Once you've got jeweler installed:

    cd hobo_support
    rake install
    cd ../hobo_fields
    rake install

That's it! We're ready to try a Rails 3 app with HoboFields. Assuming you have Rails 3 installed, use the new syntax for the `rails` command to create a new app:

    cd somewhere/for/your/test/app
    rails new test_hobofields
    cd test_hobofields

Now, the way to add a gem to a Rails 3 app, is to add the gem to Bundler's `Gemfile`. Edit that file, and add this line, at the end:

    gem 'hobo_fields', '1.3.0.pre1'

If you now run

    rails generate

You should see two Hobo generators listed in the available generators. Let's create a Hobo model (note the nice new namespaced generator syntax).

    rails generate hobo:model book name:string description:text

You can see the fields block has been added to the normal model template if you look at `app/models/book.rb`:

    class Book < ActiveRecord::Base

      fields do
        name        :string
        description :text
      end

    end

Now, let's watch HoboFields work its magic and migrate the database for us.

    rails generate hobo:migration

At the prompt, choose "m", then give the migration a name. If everything is going according to plan, the local SQLite development database should be migrated to include the `books` table. We can check at the SQLite prompt:

    rails dbconsole

Then at the SQLite prompt:

    .schema

You should see

    CREATE TABLE "books" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "description" text);
    CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
    CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");

Score! And did you notice? Domizio even gave us a *colored* prompt in the migration generator. Too much : )

