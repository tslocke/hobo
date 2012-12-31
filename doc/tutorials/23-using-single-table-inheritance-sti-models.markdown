# Using Single Table Inheritance (STI) models with Hobo

Originally written by Bryan Larsen on 2009-03-01.

Here's what I needed to do to get STI (Single Table Inheritance) working.  It's fairly straightforward, but there are a couple of gotchas.  Thus, this recipe.

The first gotcha is that you have to have your base table fully generated and migrated before you generate the child model.  See [Bug 345](http://hobo.lighthouseapp.com/projects/8324/tickets/345-inheritance-is-broken-again).

In my case:

    script/generate hobo_model_resource DownloadedFile filename:string contents:string
    script/generate hobo_migrations

I chose the "m" option for hobo\_migrations, so the database was migrated.  Then once I had the base class working:

    script/generate hobo_model_resource BatchAcknowledge

I then edited *downloaded\_file.rb* and added `sti_type :string` to the `fields` block and added `set_inheritance_column :sti_type` below the `fields` block.

I then edited *batch\_acknowledge.rb* to change its parent from `ActiveRecord::Base` to `DownloadedFile`.  I then removed everything from the file, included the fields definition and the permissions checks -- it gets those from the base class.

    script/generate hobo_migrations

If you want to add additional fields to your sub-models, you have to add them to your base model.  This is how ActiveRecord Single Table Inheritance work.  However, validations and association definitions may be added to the child model.  In my case, I added a field *submission\_id* to the base class, and added:

    belongs_to :submission
    validates_existence_of :submission

to the child class.

Now you should have working inherited models.  You'll notice that forms and pages will be generated for *BatchAcknowledge*.   Cards are not, but that's fairly irrelevant, because the *DownloadedFile* card will display a *BatchAcknowledge* record, and the auto generator would have generated the two cards identically anyways.

In another small gotcha, the name may not propogate correctly for you:  see [Bug 387](http://hobo.lighthouseapp.com/projects/8324/tickets/387-inheritance-sti-models-name-not-propagating#ticket-387-1)

A larger gotcha is that problems have been reported if you drop the database and try to run hobo_migrations:  [Bug 397](http://hobo.lighthouseapp.com/projects/8324-hobo/tickets/397-sti-problems-running-migration-on-dropped-database)

