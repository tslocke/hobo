## Creating A Blank Application

### The `hobo` command

Get yourself in a directory where you want your Hobo app to be kept, and:

    hobo pod
    
You should see the following: (lots of details removed for brevity)

    Generating Rails app...
          ...
          
    Installing classic_pagination
          ...
          
    Installing Hobo plugin...

    Initialising Hobo...
          ...

    Installing Hobo Rapid and default theme...
          ...

    Creating user model and controller...
          ...

    Creating standard pages...
          ...
          
          
A directory is created called pod, have a look at the files that have been created. This is mostly a standard Rails app, but if you are familiar with the file structure that Rails creates you will notice there are some extra things here and there. In particular you will see that Hobo has been installed in `vendor/plugins`

From here on, all the commands have to be executed in the main directory of your application.

    cd pod

### Database setup

If you're using Sqlite, `config/database.yml` is already set up for you and you don't need to create a dababase. If you're using MySQL you now need to modify `config/database.yml` and create the database.

### Migration generator
    
By default, the `hobo` command creates a user model. The database table for this model needs to be created. The migration generator can do this for us:

    ruby script/generate hobo_migration
    
You should see:

    ---------- Up Migration ----------
    create_table :users do |t|
      t.string   :crypted_password, :limit => 40
      t.string   :salt, :limit => 40
      t.string   :remember_token
      t.datetime :remember_token_expires_at
      t.string   :username
      t.boolean  :administrator, :default => false
      t.datetime :created_at
      t.datetime :updated_at
    end
    ----------------------------------

    ---------- Down Migration --------
    drop_table :users
    ----------------------------------
    What now: [g]enerate migration, generate and [m]igrate now or [c]ancel?
{: .ruby}
    
Respond with `m` and then give something like "add users" as the filename. The migration file will be created in db/migrate, and the `users` table will be created.

  
## Start the app

Launch Rails' built in development server with:

    ruby script/server
    
And point your browser at `http://localhost:3000`. You should see:

![Front Page](images/front-page.png)

## Sign-up and Log-in

You should find that you are already able to sign up as a new user, and log in and out.

We now have a basic Hobo app up and running with the default theme. Of course the app doesn't do much at this stage. To add functionality, the first step is to create some models.

Next: [Adding Models and Controllers](23-models-controllers.html)