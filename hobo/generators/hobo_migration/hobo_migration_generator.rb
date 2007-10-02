class HoboMigrationGenerator < Rails::Generator::Base

  def initialize(runtime_args, runtime_options = {})
    super
    @migration_name = runtime_args.first || begin
                                              i = Dir["#{RAILS_ROOT}/db/migrate/*hobo_migration*"].length
                                              "hobo_migration_#{i+1}"
                                            end
  end

  def manifest
    connection = ActiveRecord::Base.connection
    @types = connection.native_database_types
    
    # Force load of hobo models
    Hobo.models
    
    ignore_tables = Hobo::Migrations.ignore_tables + Hobo::Migrations.ignore.every(:pluralize)
    ignore_models = (Hobo::Migrations.ignore + Hobo::Migrations.ignore_models).every(:underscore)
    
    db_tables = connection.tables - ignore_tables
    
    models = ActiveRecord::Base.send(:subclasses).reject {|c| c.name.starts_with?("CGI::") }
    models = models.reject {|m| m.name.underscore.in?(ignore_models) }
    table_models = models.index_by {|m| m.table_name}
    model_table_names = models.every(:table_name)
    
    to_create = model_table_names - db_tables
    to_drop = db_tables - model_table_names - ['schema_info']
    to_change = db_tables & model_table_names
    
    to_rename = rename_or_drop!(to_create, to_drop, "table")
    
    renames = to_rename.map do |old_name, new_name|
      "rename_table :#{old_name}, :#{new_name}"
    end * "\n"
    undo_renames = to_rename.map do |old_name, new_name|
      "rename_table :#{new_name}, :#{old_name}"
    end * "\n"

    drops = to_drop.map do |t|
      "drop_table :#{t}"
    end * "\n"
    undo_drops = to_drop.map do |t|
      revert_table(t)
    end * "\n\n"

    creates = to_create.map do |t|
      create_table(table_models[t])
    end * "\n\n"
    undo_creates = to_create.map do |t|
      "drop_table :#{t}"
    end * "\n"
    
    changes = []
    undo_changes = []
    to_change.each do |t|
      change, undo = change_table(table_models[t])
      changes << change
      undo_changes << undo
    end
    
    up = [renames, drops, creates, changes].flatten.select{|s|!s.blank?} * "\n\n"
    down = [undo_renames, undo_drops, undo_creates, undo_changes].flatten.select{|s|!s.blank?} * "\n\n"

    if up.blank?
      puts "Database and models match -- nothing to change"
      return record {|m| } 
    end
      
    puts "\n---------- Up Migration ----------", up, "----------------------------------"
    puts "\n---------- Down Migration --------", down, "----------------------------------"
    
    action = input("What now: [g]enerate migrations, generate and [m]igrate now or [c]ancel?", %w(g m c))

    if action == 'c'
      # record nothing to keep the generator happy
      record {|m| }
    else
      puts "\nMigration filename:", "(you can type spaces instead of '_' -- every little helps)"
      migration_name = input("Filename [#@migration_name]:").strip.gsub(' ', '_')
      migration_name = @migration_name if migration_name.blank?
      
      at_exit { system "rake db:migrate" } if action == 'm'
      
      up.gsub!("\n", "\n    ")
      down.gsub!("\n", "\n    ")

      record do |m|
        m.migration_template 'migration.rb', 'db/migrate', 
                             :assigns => { :up => up, :down => down, :migration_name => migration_name.camelize }, 
                             :migration_file_name => migration_name
      end
    end
  rescue Hobo::FieldSpec::UnknownSqlTypeError => e
    puts "Invalid field type '#{e.message[2]}' for #{e.message[0]}.#{e.message[1]}"
    record {|m| }
  end
  
  def rename_or_drop!(to_create, to_drop, kind_str, name_prefix="")
    to_rename = {}
    rename_to_choices = to_create
    to_drop.dup.each do |t|
      if rename_to_choices.empty?
        puts "\nCONFIRM DROP! #{kind_str} #{name_prefix}#{t}"
        resp = input("Enter 'drop #{t}' to confirm:")
        if resp.strip != "drop " + t.to_s
          to_drop.delete(t)
        end
      else
        puts "\nDROP or RENAME?: #{kind_str} #{name_prefix}#{t}"
        puts "Rename choices: #{to_create * ', '}"
        resp = input("Enter either 'drop #{t}' or one of the rename choices:")
        resp.strip!
        
        if resp == "drop " + t
          # Leave things as they are
        else
          to_drop.delete(t)
          if resp.in?(rename_to_choices)
            to_rename[t] = resp
            to_create.delete(resp)
            rename_to_choices.delete(resp)
          end
        end
      end
    end
    to_rename
  end

  def create_table(model)
    longest_field_name = model.field_specs.values.map { |f| f.sql_type.to_s.length }.max
    (["create_table :#{model.table_name} do |t|"] +
     model.field_specs.values.sort_by{|f| f.position}.map {|f| create_field(f, longest_field_name)} +
     ["end"]) * "\n"
  end
  
  def create_field(field_spec, field_name_width)
    args = [field_spec.name.inspect] + format_options(field_spec.options, field_spec.sql_type)
    "  t.%-*s %s" % [field_name_width, field_spec.sql_type, args.join(', ')]
  end
  
  def change_table(model)
    table_name = model.table_name
    db_columns = model.connection.columns(model.table_name).index_by{|c|c.name} - [model.primary_key]
    model_column_names = model.field_specs.keys.every(:to_s)
    db_column_names = db_columns.keys.every(:to_s)
    
    to_add = model_column_names - db_column_names
    to_remove = db_column_names - model_column_names - [model.primary_key.to_sym]

    to_rename = rename_or_drop!(to_add, to_remove, "column", "#{table_name}.")

    db_column_names -= to_rename.keys
    db_column_names |= to_rename.values
    to_change = db_column_names & model_column_names
    
    renames = to_rename.map do |old_name, new_name|
      "rename_column :#{table_name}, :#{old_name}, :#{new_name}"
    end
    undo_renames = to_rename.map do |old_name, new_name|
      "rename_column :#{table_name}, :#{new_name}, :#{old_name}"
    end
    
    to_add = to_add.sort_by{|c| model.field_specs[c].position }
    adds = to_add.map do |c|
      spec = model.field_specs[c]
      args = [":#{spec.sql_type}"] + format_options(spec.options, spec.sql_type)
      "add_column :#{table_name}, :#{c}, #{args * ', '}"
    end
    undo_adds = to_add.map do |c|
      "remove_column :#{table_name}, :#{c}"
    end
    
    removes = to_remove.map do |c|
      "remove_column :#{table_name}, :#{c}"
    end
    undo_removes = to_remove.map do |c|
      revert_column(table_name, c)
    end
    
    old_names = to_rename.invert
    changes = []
    undo_changes = []
    to_change.each do |c|
      col_name = old_names[c] || c
      col = db_columns[col_name]
      spec = model.field_specs[c]
      if spec.different_to?(col)
        change_spec = {}
        change_spec[:limit]     = spec.limit if !spec.limit.nil?
        change_spec[:precision] = spec.precision if !spec.precision.nil?
        change_spec[:scale]     = spec.scale if !spec.scale.nil?
        change_spec[:null]      = false unless spec.null
        change_spec[:default]   = spec.default if !spec.default.nil?
        
        changes << "change_column :#{table_name}, :#{c}, " + 
          ([":#{spec.sql_type}"] + format_options(change_spec, spec.sql_type)).join(", ")
        back = change_column_back(table_name, c)
        undo_changes << back unless back.blank?
      else
        nil
      end
    end.compact
    
    [(renames + adds + removes + changes) * "\n",
     (undo_renames + undo_adds + undo_removes + undo_changes) * "\n"]
  end
  
  
  def format_options(options, type)
    options.map do |k, v|
      next if k == :limit && (type == :decimal || v == @types[type][:limit])
      next if k == :null && v == true
      "#{k.inspect} => #{v.inspect}" 
    end.compact
  end
  
  
  def revert_table(table)
    res = StringIO.new
    ActiveRecord::SchemaDumper.send(:new, ActiveRecord::Base.connection).send(:table, table, res)
    res.string.strip.gsub("\n  ", "\n")
  end
  
  def column_options_from_reverted_table(table, column)
    revert = revert_table(table)
    if (md = revert.match(/\s*t\.column\s+"#{column}",\s+(:[a-zA-Z0-9_]+)(?:,\s+(.*?)$)?/m))
      # Ugly migration
      _, type, options = *md
    elsif (md = revert.match(/\s*t\.([a-z_]+)\s+"#{column}"(?:,\s+(.*?)$)?/m))
      # Sexy migration
      _, type, options = *md
      type = ":#{type}"
    end
    [type, options]
  end
  
  
  def change_column_back(table, column)
    type, options = column_options_from_reverted_table(table, column)
    "change_column :#{table}, :#{column}, #{type}#{', ' + options.strip if options}"
  end

  def revert_column(table, column)
    type, options = column_options_from_reverted_table(table, column)
    "add_column :#{table}, :#{column}, #{type}#{', ' + options.strip if options}"
  end
  
  
  def input(prompt, options=nil)
    print(prompt + " ")
    if options
      while !(response = STDIN.readline.strip.downcase).in?(options); 
        print(prompt + " ")
      end
      response
    else
      STDIN.readline
    end
  end
  
end

