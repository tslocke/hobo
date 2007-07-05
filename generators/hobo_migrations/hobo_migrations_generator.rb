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
    
    missing_tables = model_table_names - connection.tables
    extra_tables = connection.tables - model_table_names - ['schema_info']
    changed_tables = connection.tables & model_table_names
    
    drops = extra_tables.map do |t|
      "drop_table :#{t}"
    end * "\n\n"
    
    creates = missing_tables.map do |t|
      create_table(table_models[t])
    end * "\n\n"
    
    changes = changed_tables.map do |t|
      change_table(table_models[t])
    end * "\n\n"
    
    
    up = [drops, "", creates, "", changes] * "\n"
    
    up.gsub!("\n", "\n    ")
    
    down = ""
    
    puts up, ""
    
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate', 
                           :assigns => { :up => up, :down => down, :migration_name => @migration_name.camelize }, 
                           :migration_file_name => @migration_name unless
        up.blank? && down.blank?
    end
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
    db_columns = model.connection.columns(model.table_name).index_by{|c|c.name.to_sym}
    model_column_names = model.field_specs.keys
    db_column_names = db_columns.keys
    
    missing_columns = model_column_names - db_column_names
    extra_columns = db_column_names - model_column_names - [model.primary_key.to_sym]
    changed_columns = db_column_names & model_column_names
    
    adds = missing_columns.map do |c|
      spec = model.field_specs[c]
      args = [":#{spec.sql_type}"] + format_options(spec.options, spec.sql_type)
      "add_column :#{model.table_name}, :#{c}, #{args * ', '}"
    end
    
    removes = extra_columns.map do |c|
      "remove_column :#{model.table_name}, :#{c}"
    end
    
    changes = changed_columns.map do |c|
      col = db_columns[c]
      spec = model.field_specs[c]
      if spec.different_to?(col)
        change_spec = {}
        change_spec[:type]      = spec.sql_type
        change_spec[:limit]     = spec.limit if col.type != :decimal && !spec.limit.nil?
        change_spec[:precision] = spec.precision if !spec.precision.nil?
        change_spec[:scale]     = spec.scale if !spec.scale.nil?
        change_spec[:null]      = false unless spec.null
        change_spec[:default]   = spec.default if !spec.default.nil?
        "change_column :#{model.table_name}, #{c.inspect}, " + 
          format_options(change_spec, spec.sql_type).join(", ")
      else
        nil
      end
    end.compact
    
    (adds + removes + changes) * "\n"
  end
  
  def format_options(options, type)
    options.map{|k, v| "#{k.inspect} => #{v.inspect}" unless k == :limit && v == @types[type][:limit] }.compact
  end
  
end

