class HoboMigrationsGenerator < Rails::Generator::NamedBase

  def initialize(runtime_args, runtime_options = {})
    super
    @migration_name = runtime_args.first
  end

  def manifest
    connection = ActiveRecord::Base.connection
    @types = connection.native_database_types
    models = ActiveRecord::Base.send(:subclasses).reject {|c| c.name.starts_with?("CGI::") }
    table_models = models.index_by {|m| m.table_name}
    model_table_names = models.every(:table_name)
    
    to_create = model_table_names - connection.tables
    to_drop = connection.tables - model_table_names - ['schema_info']
    to_change = connection.tables & model_table_names
    
    to_rename = rename_or_drop!(to_create, to_drop, "table")
    
    renames = to_rename.map do |old_name, new_name|
      "rename_table :#{old_name}, :#{new_name}"
    end * "\n"
    
    drops = to_drop.map do |t|
      "drop_table :#{t}"
    end * "\n"
    
    creates = to_create.map do |t|
      create_table(table_models[t])
    end * "\n\n"
    
    changes = to_change.map do |t|
      change_table(table_models[t])
    end * "\n\n"
    
    up = [renames, drops, creates, changes].select{|s|!s.blank?}.join("\n\n")
    
    down = ""
    
    puts "\n---------- Up Migration ----------", up, "----------------------------------"
    
    ok = input("OK? [Yn]:").strip.downcase != "n"
    
    up.gsub!("\n", "\n    ")
    
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate', 
                           :assigns => { :up => up, :down => down, :migration_name => @migration_name.camelize }, 
                           :migration_file_name => @migration_name if ok && !up.blank?
    end
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
      (["create_table :#{model.table_name} do |t|"] +
       model.field_specs.values.map {|f| create_field(f)} +
       ["end"]) * "\n"
  end
  
  def create_field(field_spec)
    args = [field_spec.name.inspect] + format_options(field_spec.options, field_spec.sql_type)
    "  t.#{field_spec.sql_type} #{args * ', '}"
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
    
    to_add = to_add.sort_by{|c| model.field_specs[c].position }
    adds = to_add.map do |c|
      spec = model.field_specs[c]
      args = [":#{spec.sql_type}"] + format_options(spec.options, spec.sql_type)
      "add_column :#{table_name}, :#{c}, #{args * ', '}"
    end
    
    removes = to_remove.map do |c|
      "remove_column :#{table_name}, :#{c}"
    end
    
    old_names = to_rename.invert
    changes = to_change.map do |c|
      col_name = old_names[c] || c
      col = db_columns[col_name]
      spec = model.field_specs[c.to_sym]
      if spec.different_to?(col)
        change_spec = {}
        change_spec[:type]      = spec.sql_type
        change_spec[:limit]     = spec.limit if !spec.limit.nil?
        change_spec[:precision] = spec.precision if !spec.precision.nil?
        change_spec[:scale]     = spec.scale if !spec.scale.nil?
        change_spec[:null]      = false unless spec.null
        change_spec[:default]   = spec.default if !spec.default.nil?
        "change_column :#{table_name}, :#{c}, " + 
          format_options(change_spec, spec.sql_type).join(", ")
      else
        nil
      end
    end.compact
    
    (renames + adds + removes + changes) * "\n"
  end
  
  def format_options(options, type)
    options.map do |k, v|
      next if k == :limit && (type == :decimal || v == @types[type][:limit])
      next if k == :null && v == true
      "#{k.inspect} => #{v.inspect}" 
      end.compact
  end
  
  def input(prompt)
    print(prompt + " ")
    STDIN.readline
  end
  
end

