--- 
wordpress_id: 161
author_login: admin
layout: post
comments: 
- author: Alex G
  date: Fri Jul 06 17:49:41 +0000 2007
  id: 6990
  content: |
    <p>That's hot! </p>
    
    <p>I hate migrations. The idea is good but implementation is miserable. </p>
    
    <p>Any chance of turning this into a stand-alone plugin?</p>

  date_gmt: Fri Jul 06 17:49:41 +0000 2007
  author_email: lemzazul@hotmail.com
  author_url: http://www.noobkit.com
- author: Shalev
  date: Fri Jul 06 18:37:00 +0000 2007
  id: 6994
  content: |
    <p>Vunderbar!</p>
    
    <p>I'll second the request for extracting this into a plugin.  It sounds quite useful to all developers.</p>

  date_gmt: Fri Jul 06 18:37:00 +0000 2007
  author_email: pugiox@gmail.com
  author_url: ""
- author: s0lnic
  date: Fri Jul 06 19:20:22 +0000 2007
  id: 6996
  content: |
    <p>Very nice Tom :) </p>
    
    <p>This could be a revolution for rails developers. In my opinion this is exactly how things should work. In Django (and not only) you declare fields inside models, but AFAIR they don't have any migrations there, so it's not possible to rollback changes.</p>
    
    <p>I'm sure that this will show up in the rails core someday :)</p>
    
    <p>Cheers!</p>

  date_gmt: Fri Jul 06 19:20:22 +0000 2007
  author_email: ""
  author_url: ""
- author: Wink
  date: Fri Jul 06 19:43:27 +0000 2007
  id: 7000
  content: |
    <p>Very cool. I can't stand shuffling back and forth between migration scripts and code just to remember what fields my model has. I'll definitely be using this going forward.</p>

  date_gmt: Fri Jul 06 19:43:27 +0000 2007
  author_email: mwinkelspecht@gmail.com
  author_url: ""
- author: Leonardo Herrera
  date: Fri Jul 06 19:52:55 +0000 2007
  id: 7001
  content: |
    <p>I can't wait!</p>

  date_gmt: Fri Jul 06 19:52:55 +0000 2007
  author_email: leus@epublish.cl
  author_url: http://leus.epublish.cl/
- author: dr
  date: Fri Jul 06 23:14:49 +0000 2007
  id: 7011
  content: |
    <p>I think this is terrific and that is definitely where tables should be defined.  I can't tell you how many times I've had to go back and look at migrations or poke at the database to remember what the structure is.  Hope this will make it into core.</p>
    
    <p>How are indexes handled?  How about sql for those times you can't get exactly what you want?</p>

  date_gmt: Fri Jul 06 23:14:49 +0000 2007
  author_email: ""
  author_url: ""
- author: Peter Jaros
  date: Fri Jul 06 23:57:53 +0000 2007
  id: 7013
  content: |
    <p>Thank you, Tom.  You've given me a valid retroactive reason not to have built that website yet.  Soon I'll have no excuse.  :)</p>

  date_gmt: Fri Jul 06 23:57:53 +0000 2007
  author_email: peter.a.jaros@gmail.com
  author_url: ""
- author: "Morning Brew #53"
  date: Sat Jul 07 10:51:08 +0000 2007
  id: 7046
  content: |
    <p>[...] Hobo migrations - I like! Getting rid of migration files all together and putting it where it belongs - in the model itself. [...]</p>

  date_gmt: Sat Jul 07 10:51:08 +0000 2007
  author_email: ""
  author_url: http://www.sameshirteveryday.com/2007/07/07/morning-brew-53/
- author: ylon
  date: Sun Jul 08 01:40:19 +0000 2007
  id: 7081
  content: |
    <p>You know Tom, you really keep raining on our proverbial parade with these spectacular new announcements.  Please stop! ;) j/k</p>
    
    <p>Truly though, I feel the same in terms of procrastinating my projects.  How safe are we to check out your source and start using it?  I'm going to do it, but I am just wondering how much trouble I'll be in and how closely I'm going to need to watch your changes on an ongoing basis.</p>

  date_gmt: Sun Jul 08 01:40:19 +0000 2007
  author_email: lists@southernohio.net
  author_url: ""
- author: Tom
  date: Sun Jul 08 10:10:55 +0000 2007
  id: 7090
  content: |
    <p>Thanks for the positive feedback people :-)</p>
    
    <p>Just to clarify one thing. Migrations haven't gone away at all - I realise the title of the post was a bit misleading (I've changed it).</p>
    
    <p>The point is that migrations are completely unchanged by this feature. It's just that you don't have to write them yourself. If you want to do extra stuff like creating indexes or munging your data in some way, just edit the generated file. You never use the generator to regenerate the same migration later, so you won't run into the classic problem of overwriting your edits.</p>
    
    <p>I agree that this would be very nice as a separate plugin, but personally I'm totally focussed on making Hobo as good as it can be right now. If anyone wants to extract this feature, the MIT license permits it and you're very welcome.</p>

  date_gmt: Sun Jul 08 10:10:55 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Mejorando las migraciones en Rails at Putting it together
  date: Sun Jul 08 15:37:45 +0000 2007
  id: 7101
  content: |
    <p>[...] Me encuentro, leyendo los blogs de algunos de los ponentes de la pr&Atilde;&sup3;xima RailsConf Europe, con esta propuesta que pretende hacer m&Atilde;&iexcl;s f&Atilde;&iexcl;cil la vida del desarrollador de backend en Rails. [...]</p>

  date_gmt: Sun Jul 08 15:37:45 +0000 2007
  author_email: ""
  author_url: http://blog.lmcavalle.com/2007/07/08/mejorando-las-migraciones-en-rails/
- author: Niko
  date: Sun Jul 08 21:11:40 +0000 2007
  id: 7113
  content: |
    <p>Now where's that time machine to beam us to the end of the month?</p>

  date_gmt: Sun Jul 08 21:11:40 +0000 2007
  author_email: ni-di@web.de
  author_url: ""
- author: Niko
  date: Mon Jul 09 07:54:38 +0000 2007
  id: 7140
  content: |
    <p>Where would one define columns for STI models? The common columns in the parent class and the specific in the child classes? Or all columns in the parent classes?</p>

  date_gmt: Mon Jul 09 07:54:38 +0000 2007
  author_email: ni-di@web.de
  author_url: ""
- author: Tom
  date: Mon Jul 09 08:16:55 +0000 2007
  id: 7141
  content: |
    <p>Niko - eek! Good question. I haven't thought about STI yet. It's probably buggy - I'll go sort that :-)</p>
    
    <p>Once fixed, the answer to your question will be... um... I think the common in the parent and the specific in the subclasses. It's unlikely but conceivable that the subclass may re-type a field, e.g. changing plain text to HTML.</p>

  date_gmt: Mon Jul 09 08:16:55 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Niko
  date: Mon Jul 09 08:51:58 +0000 2007
  id: 7142
  content: |
    <p>Another aspect of STI is assoziations defined for just one subclass. One can't choose where to put those so Hobo has to look in the subclasses anyway to find the foreign key requirements.</p>

  date_gmt: Mon Jul 09 08:51:58 +0000 2007
  author_email: ni-di@web.de
  author_url: ""
- author: Dr Nic
  date: Tue Jul 10 19:03:35 +0000 2007
  id: 7220
  content: |
    <p>+1 to make it a separate plugin, and to make it a rails patch</p>
    
    <p>The last thing that was extracted into rails from hobo came via errtheblog and hobo got no recognition for it.</p>

  date_gmt: Tue Jul 10 19:03:35 +0000 2007
  author_email: drnicwilliams@gmail.com
  author_url: http://drnicwilliams.com
- author: robert
  date: Thu Jul 12 16:05:10 +0000 2007
  id: 7318
  content: |
    <p>i really like the new feature. defining your data objects in the Model layer makes more sense than the migration layer to me. </p>
    
    <p>i have a question:
    where do i put the code sections that i previously had in my migration scripts if i use the new migration generator? for example, if i start a new hobo rails app i get users by default. the users migration script has the following code in it:</p>
    
    <p><code># create the admin user now because we can't do it
        # through the web UI as it would fail validation
        admin = User.new
        admin.nick_name = 'admin'
        admin.first_name = 'admin'
        admin.last_name = 'admin'
        admin.email = 'admin'
        admin.password = 'password'
        admin.save_without_validation
    </code></p>
    
    <p>how do i preserve this functionality now that my migration script is generated?</p>
    
    <p>thanks.</p>

  date_gmt: Thu Jul 12 16:05:10 +0000 2007
  author_email: robert.moore@openlogic.com
  author_url: ""
- author: Tom
  date: Thu Jul 12 16:23:35 +0000 2007
  id: 7320
  content: |
    <p>Robert - please see my previous comment (10)</p>

  date_gmt: Thu Jul 12 16:23:35 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: robert
  date: Thu Jul 12 17:11:50 +0000 2007
  id: 7321
  content: |
    <p>RE: 18:
    that makes sense, however, now you are having to create the fields in the Model and then go edit the generated migration script. have you given any thought to expanding the migration generator to include such functionality as indexing and including generic "code sections" (that basically just copies a chunk of code, such as the previously mentioned 'add user' code, to the migration script during the generate process)?</p>
    
    <p>thanks again.</p>

  date_gmt: Thu Jul 12 17:11:50 +0000 2007
  author_email: robert.moore@openlogic.com
  author_url: ""
- author: Fredrik Br&Atilde;&curren;nstr&Atilde;&para;m
  date: Sat Jul 14 07:28:30 +0000 2007
  id: 7396
  content: |
    <p>Definately make this a separate plugin. I want it now!</p>

  date_gmt: Sat Jul 14 07:28:30 +0000 2007
  author_email: branstrom@gmail.com
  author_url: http://branstrom.name
- author: Jabari Zakiya
  date: Fri Jul 20 23:34:53 +0000 2007
  id: 7826
  content: |
    <p>You know, you're getting pretty close to what DRYSql
    is about.</p>
    
    <p>http://drysql.rubyforge.org/
    http://rubyforge.org/projects/drysql/</p>
    
    <p>I think what it/you are doing should/will eventually be apart of Rails core (with all the customization and legacy options available) but all you should have to do is profile your models/tables in one place and let the software work for you thereafter, instead of vice versa.</p>
    
    <p>Only thing though, I keep holding off on using Hobo until it gets all these goodies in place so I don't have to go back and redo my project. :>)</p>

  date_gmt: Fri Jul 20 23:34:53 +0000 2007
  author_email: jzakiya@mail.com
  author_url: http://jzakiya.blogspot.com
- author: Tom
  date: Sat Jul 21 15:46:50 +0000 2007
  id: 7846
  content: |
    <p>Jabari - I'd say what we're doing here is exactly opposite to DRYSQL. DRYSQL says "make my app behave exactly as the database schema says it should", while this migration generator says "make the database structure be exactly what my application source-code says it should be".</p>

  date_gmt: Sat Jul 21 15:46:50 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Tom
  date: Sat Jul 21 15:54:06 +0000 2007
  id: 7847
  content: |
    <blockquote>
      <p>Only thing though, I keep holding off on using Hobo until it gets all these goodies in place so I don&acirc;&euro;&trade;t have to go back and redo my project. :>)</p>
    </blockquote>
    
    <p>Very sensible! :-)</p>

  date_gmt: Sat Jul 21 15:54:06 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: Jabari Zakiya
  date: Sat Jul 21 19:47:34 +0000 2007
  id: 7851
  content: |
    <p>Heh Tom,</p>
    
    <p>What I was alluding to was the concept of DRYing up the process generating the details of the models relationship to the database.</p>
    
    <p>Here's what Bryan Adams says DRYSQL purpose is.
    http://www.infoq.com/articles/DrySQL
    http://allyourdatabase.blogspot.com/2006/11/introducing-drysql.html</p>
    
    <p>Magic Models is also doing a similar thing.
    http://magicmodels.rubyforge.org/dr<em>nic</em>magic_models/</p>
    
    <p>Philosophically though, what you and the other projects have identified is the chance/ability, to DRYup the modeling/migration/database creation of the process more than what Rails natively does. You're extending DRY philosophy to more components of the process, and taking the drudgery of physically having to do all of these repetitive standard things by hand. Hey, format it right and just let the framework do it for you!</p>
    
    <p>Again, it seems so logical upon looking at the design now, but when you're pioneering a whole new paradigm shift, its hard (nay impossible) to recognize all of the optimizations at once.</p>
    
    <p>A year from now, when Ruby and Rails hit 2.0, Rails will be so much more DRYed out and efficient the days of the 1.xx series will seem like pre-history, like when people wrote assembly language (or at least C) code. :>)</p>

  date_gmt: Sat Jul 21 19:47:34 +0000 2007
  author_email: jzakiya@mail.com
  author_url: http://jzakiya.blogspot.com
- author: Jabari Zakiya
  date: Sat Jul 21 19:55:03 +0000 2007
  id: 7852
  content: |
    <p>Opps. Its Bryan Evans not Bryan Adams.</p>

  date_gmt: Sat Jul 21 19:55:03 +0000 2007
  author_email: jzakiya@mail.com
  author_url: http://jzakiya.blogspot.com
- author: s.m. koppelman
  date: Thu Jul 26 20:12:18 +0000 2007
  id: 8014
  content: |
    <p>I mean this is nice and all, but who needs to rummage through old migrations to figure out what columns are in a table? Surely you didn't do all this just because you never noticed the schema.rb/schema.sql file that gets generated after running a migration? :)</p>

  date_gmt: Thu Jul 26 20:12:18 +0000 2007
  author_email: reg1@hatless.com
  author_url: http://www.hatless.com/
- author: Nick Carter
  date: Fri Jul 27 07:37:32 +0000 2007
  id: 8037
  content: |
    <p>That. Is. Sweet. And I'm almost ready to seriously start playing with Hobo!</p>

  date_gmt: Fri Jul 27 07:37:32 +0000 2007
  author_email: thynctank@gmail.com
  author_url: http://thynctank.com
- author: thyncology &raquo; Blog Archive &raquo; Nutech, ad nauseum
  date: Mon Jul 30 19:26:44 +0000 2007
  id: 8255
  content: |
    <p>[...] So when writing migrations gets you down, know that just around the corner is a whole new sexy migration tool from Tom at Hobo Central. Tom is responsible for the current &#8220;sexy migrations&#8221; trend in Rails and has some amazing ideas. The new tool allows you to define all columns and relationships within the models themselves, and based upon the comparison between current models and previous schema, the migration generator migration files to do all the work of both up and down methods! That&#8217;s right, no more typing redundant&Acirc;&nbsp; code which is just a mirror of the previous method def! I&#8217;d love to see this implemented in core Rails. Let us pray&#8230; [...]</p>

  date_gmt: Mon Jul 30 19:26:44 +0000 2007
  author_email: ""
  author_url: http://www.thynctank.com/rails/2007/07/nutech-ad-nauseum/
- author: cakebaker &raquo; Should the table definition be in the model?
  date: Sat Aug 04 15:21:18 +0000 2007
  id: 8578
  content: |
    <p>[...] That&#8217;s a question I ask myself after reading an article about an alternative approach to realize migrations in Rails. With that approach, you define the columns of your table in the model and then you generate the migration files from the model. You no longer have to touch any SQL scripts or to write migration files &#8212; if there are changes in the table definition, you make them in the model. [...]</p>

  date_gmt: Sat Aug 04 15:21:18 +0000 2007
  author_email: ""
  author_url: http://cakebaker.42dh.com/2007/08/04/should-the-table-definition-be-in-the-model/
- author: Steven Borg
  date: Mon Aug 27 01:46:16 +0000 2007
  id: 9707
  content: |
    <p>I'd love to see a switch to make the migration silent.  For instance:</p>
    
    <p>script/generate hobo<em>migrations my</em>migration -g (or -c, -m)</p>
    
    <p>It's an easy add, but I'm not yet feeling comfortable submitting a possible diff...</p>

  date_gmt: Mon Aug 27 01:46:16 +0000 2007
  author_email: steven_borg@yahoo.com
  author_url: ""
- author: Tom
  date: Mon Aug 27 08:14:52 +0000 2007
  id: 9716
  content: |
    <p>Steven - We've also had that request from who wants to hook up the migration to a button in an IDE. The problem is that the generator is interactive. If it sees a field named "a" that is not in the database, and a DB column named "b" that is not in the model, it asks you if you are renaming "b" to "a', or removing "b" and creating "a".</p>
    
    <p>The other issue is that I think it's really important to <em>show</em> the migration code before generating the files, so folk get a chance to check it's what they intended.</p>

  date_gmt: Mon Aug 27 08:14:52 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: patrick
  date: Thu Aug 30 23:40:17 +0000 2007
  id: 9867
  content: |
    <p>I had a default value on a :text and it screamed at me.</p>
    
    <p>my model:</p>
    
    <p>fields do
        name :string, :null => false
        email :string
        about :text, :default => "No description available"
        timestamps
      end</p>
    
    <p>the migration step:</p>
    
    <p>What now: [g]enerate migrations, generate and [m]igrate now or [c]ancel? m
          create  db/migrate
          create  db/migrate/001<em>create</em>initial<em>tables.rb
    (in /Users/home/Development/test)
    == 1 CreateInitialTables: migrating ===========================================
    -- create</em>table(:foomodels)
    rake aborted!
    Mysql::Error: BLOB/TEXT column 'about' can't have a default value: CREATE TABLE foomodels (<code>id</code> int(11) DEFAULT NULL auto_increment PRIMARY KEY, <code>name</code> varchar(255) NOT NULL, <code>email</code> varchar(255) DEFAULT NULL, <code>about</code> text DEFAULT 'No description available', <code>created_at</code> datetime DEFAULT NULL, <code>updated_at</code> datetime DEFAULT NULL) ENGINE=InnoDB</p>
    
    <p>Taking out the default value (rming the db/migrate/001<em>create</em>initial_tables.rb file) and retrying made it go through.  Is there a reason why it died with a default value for :text  ?</p>
    
    <p>Thanks, Hobo rocks.</p>

  date_gmt: Thu Aug 30 23:40:17 +0000 2007
  author_email: pclapp@gmail.com
  author_url: ""
- author: Tom
  date: Fri Aug 31 08:00:11 +0000 2007
  id: 9886
  content: |
    <p>patrick - looks like MySQL doesn't support that</p>

  date_gmt: Fri Aug 31 08:00:11 +0000 2007
  author_email: tom@hobocentral.net
  author_url: http://www.hobocentral.net
- author: labrat
  date: Tue Sep 18 17:23:50 +0000 2007
  id: 10790
  content: |
    <p>This makes so much more sense rather than using the annotate_models plugin.  Plus, the current migrations clash with the ActiveRecord namespace.  The core team really needs to rethink migrations.</p>

  date_gmt: Tue Sep 18 17:23:50 +0000 2007
  author_email: richstyles@gmail.com
  author_url: http://blog.labratz.net
author: Tom
title: The Hobo Migration Generator
excerpt: |
  Right back at the start of the Hobo project we made writing migrations a little easier. We made it so you didn't have to write the word "column" quite so many times. 
  
      create_table "users" do |t|
        t.column :name, :string
      end
      
  Became:
  
      create_table "users" do |t|
        t.string :name
      end
  
  A pretty small contribution in the scheme of things, but kinda handy, and it made it into core Rails (by a circuitous route) which was nice.
  
  Somehow though, it wasn't good enough. It was quicker, but it wasn't Hobo Quick. Don't you always get the feeling that writing migrations is kinda mechanical? Especially those tedious down migrations. Don't you wish you never had to write another migration again? I know I do. Or did, I should say.
  
  Announcing the Hobo Migration Generator.
  

published: true
tags: []

date: 2007-07-06 16:14:35 +00:00
categories: 
- General
author_email: tom@hobocentral.net
wordpress_url: http://hobocentral.net/blog/2007/07/06/so-long-migrations/
author_url: http://www.hobocentral.net
status: publish
---
Right back at the start of the Hobo project we made writing migrations a little easier. We made it so you didn't have to write the word "column" quite so many times. 

    create_table "users" do |t|
      t.column :name, :string
    end
    
Became:

    create_table "users" do |t|
      t.string :name
    end

A pretty small contribution in the scheme of things, but kinda handy, and it made it into core Rails (by a circuitous route) which was nice.

Somehow though, it wasn't good enough. It was quicker, but it wasn't Hobo Quick. Don't you always get the feeling that writing migrations is kinda mechanical? Especially those tedious down migrations. Don't you wish you never had to write another migration again? I know I do. Or did, I should say.

Announcing the Hobo Migration Generator.

<a id="more"></a><a id="more-161"></a>

Creating your database tables in the next version of Hobo will go something like this:

Step 1. Code your models (being sure not to generate any migrations)

Step 2. `ruby script/generate hobo_migration create_initial_tables`

(Step 2.5. Observe `db/migrate/001_create_initial_tables.rb`)

Step 3. `rake db:migrate`

And you're done.

Hang on one darn minute I hear you say! Where are the columns declared? One of the much loved features of Active Record is that you don't have to enumerate the columns in your models - AR interrogates the database and finds them for you. If Hobo generated the migration, where were the columns declared?

In the model class.

    class User < ActiveRecord::Base
      fields do
        name :string, :null => false
        email :string
        about :text, :default => "No description available"
      end
    end
    
Sacrilege! Not at all - it's actually much better this way. Work with me for a minute here.

What is it that you really love about not having to list the columns in your AR classes? It's the fact that it's DRY. You don't have to list them once in the migration and then again in the class. Well that's still true, all we've done is moved those declarations to where they should be - in the same place that defines all the rest of the behaviour of your model. Yes those column declarations will be in the migration too, but that is generated for you.

There's no more trawling through old migrations or messing with MySQL in order to remind yourself what columns you have - it's right there in your code.

The generator looks at the database, looks at your models, figures out the difference and creates a migration such that the database gets with the program.

It generates the down migration too of course.

Moving forward things get even more interesting. Say you wanted to get rid of one of those fields. Just delete it from the `fields` declaration. Run the migration generator again and you'll get a `remove_column` migration. Change the type of a column or add a default? No problem, you'll get a `change_column`.

What if you delete a model class outright? Well we're guessing your production data is kind of important to you, so the generator is interactive. It will require you to physically type "drop users" (or whatever) before it will generate a `drop_table` migration. The same goes for removing columns in fact.

What about renaming a column or table? Those are kinda tricky. Say we rename the field `name` to `username`. All the generator sees is that an existing field `name` has gone away, and a new field `username` has appeared on the scene. The generator will alert you to the ambiguity and invite you to enter either "drop name" or the new name "username".

That's the long and short of it, but there's a couple more niceties.

Inside the `fields` block you can say simply `timestamps` to get `created_at` and `updated_at`.

You can declare fields using Hobo's rich types like `:html` and `:markdown`. These end up as `:text` columns unless you override that by giving the `:sql_type` option. Your DRYML tags will know what it really is and render appropriately.
    
As for foreign keys -- don't even bother. Just declare `belongs_to` as you normally would, and the migration generator will spot the need to add a foreign key. Either with the conventional name or a custom one if you gave the `:foreign_key` option. Delete the `belongs_to` later, and the migration generator will remove the foreign key.

If, like most Rails programmers, you've written a *lot* of migrations, I think you'll find using this puppy to be a fairly pleasing experience :-) I know I do.

It's working now in the `tom_sandbox` branch, and will be in the next release, which, if the coding gods be willing, will be out by the end of the month.
