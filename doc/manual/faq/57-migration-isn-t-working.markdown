# migration isn't working

Originally written by kevinpfromnm on 2010-08-04.

I had everything setup and working.  then setup mod_ruby (enterprise
ruby)  and thing stopped working.   I've removed everything and
reloaded ruby rails and hobo and still am getting errors..   any
ideas?

    spokra@devoz:/var/hobo/gbnt$ script/generate  hobo_model_resource site
    user_id:integer street:string number:integer
          exists  app/models/
          exists  app/controllers/
          exists  app/helpers/
          create  app/views/sites
          exists  test/functional/
          exists  test/unit/
      dependency  hobo_model
          exists    app/models/
          exists    test/unit/
          exists    test/fixtures/
          create    app/viewhints
          create    app/models/site.rb
          create    app/viewhints/site_hints.rb
          create    test/unit/site_test.rb
          create    test/fixtures/sites.yml
          create  app/controllers/sites_controller.rb
          create  test/functional/sites_controller_test.rb
          create  app/helpers/sites_helper.rb
    spokra@devoz:/var/hobo/gbnt$ script/generate hobo_migration
    
    ---------- Up Migration ----------
    create_table :sites do |t|
      t.integer  :user_id
      t.string   :street
      t.integer  :number
      t.datetime :created_at
      t.datetime :updated_at
    end
    ----------------------------------
    
    ---------- Down Migration --------
    drop_table :sites
    ----------------------------------
    What now: [g]enerate migration, generate and [m]igrate now or
    [c]ancel? m
    
    Migration filename:
    (you can type spaces instead of '_' -- every little helps)
    Filename [hobo_migration_1]: site
          exists  db/migrate
          create  db/migrate/20100802151728_site.rb
    (in /var/hobo/gbnt)
    rake aborted!
    An error has occurred, all later migrations canceled:
    
    superclass mismatch for class Site
    
    (See full trace by running task with --trace)
    
    spokra@devoz:/var/hobo/gbnt$ rake db:migrate --trace
    (in /var/hobo/gbnt)
    ** Invoke db:migrate (first_time)
    ** Invoke environment (first_time)
    ** Execute environment
    ** Execute db:migrate
    rake aborted!
    An error has occurred, all later migrations canceled:
    
    superclass mismatch for class Site
    ./db/migrate//20100802151728_site.rb:1
    /var/lib/gems/1.8/gems/activesupport-2.3.8/lib/active_support/
    dependencies.rb:145:in `load_without_new_constant_marking'
    /var/lib/gems/1.8/gems/activesupport-2.3.8/lib/active_support/
    dependencies.rb:145:in `load'
    /var/lib/gems/1.8/gems/activesupport-2.3.8/lib/active_support/
    dependencies.rb:521:in `new_constants_in'
    /var/lib/gems/1.8/gems/activesupport-2.3.8/lib/active_support/
    dependencies.rb:145:in `load'
    /var/lib/gems/1.8/gems/activerecord-2.3.8/lib/active_record/
    migration.rb:373:in `load_migration'
    /var/lib/gems/1.8/gems/activerecord-2.3.8/lib/active_record/
    migration.rb:369:in `migration'
    (__DELEGATION__):2:in `migrate'
    /var/lib/gems/1.8/gems/activerecord-2.3.8/lib/active_record/
    migration.rb:491
    /var/lib/gems/1.8/gems/activerecord-2.3.8/lib/active_record/
    migration.rb:567:in `call'
    /var/lib/gems/1.8/gems/activerecord-2.3.8/lib/active_record/
    migration.rb:567:in `ddl_transaction'
    /var/lib/gems/1.8/gems/activerecord-2.3.8/lib/active_record/
    migration.rb:490:in `migrate'
    /var/lib/gems/1.8/gems/activerecord-2.3.8/lib/active_record/
    migration.rb:477:in `each'
    /var/lib/gems/1.8/gems/activerecord-2.3.8/lib/active_record/
    migration.rb:477:in `migrate'
    /var/lib/gems/1.8/gems/activerecord-2.3.8/lib/active_record/
    migration.rb:401:in `up'
    /var/lib/gems/1.8/gems/activerecord-2.3.8/lib/active_record/
    migration.rb:383:in `migrate'
    /var/lib/gems/1.8/gems/rails-2.3.8/lib/tasks/databases.rake:112
    /var/lib/gems/1.8/gems/rake-0.8.7/lib/rake.rb:636:in `call'
    /var/lib/gems/1.8/gems/rake-0.8.7/lib/rake.rb:636:in `execute'
    /var/lib/gems/1.8/gems/rake-0.8.7/lib/rake.rb:631:in `each'
    /var/lib/gems/1.8/gems/rake-0.8.7/lib/rake.rb:631:in `execute'
    /var/lib/gems/1.8/gems/rake-0.8.7/lib/rake.rb:597:in
    `invoke_with_call_chain'
    /usr/lib/ruby/1.8/monitor.rb:242:in `synchronize'
    /var/lib/gems/1.8/gems/rake-0.8.7/lib/rake.rb:590:in
    `invoke_with_call_chain'
    /var/lib/gems/1.8/gems/rake-0.8.7/lib/rake.rb:583:in `invoke'
    /var/lib/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2051:in `invoke_task'
    /var/lib/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2029:in `top_level'
    /var/lib/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2029:in `each'
    /var/lib/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2029:in `top_level'
    /var/lib/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2068:in
    `standard_exception_handling'
    /var/lib/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2023:in `top_level'
    /var/lib/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2001:in `run'
    /var/lib/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2068:in
    `standard_exception_handling'
    /var/lib/gems/1.8/gems/rake-0.8.7/lib/rake.rb:1998:in `run'
    /var/lib/gems/1.8/gems/rake-0.8.7/bin/rake:31
    /usr/local/bin/rake:19:in `load'
    /usr/local/bin/rake:19 