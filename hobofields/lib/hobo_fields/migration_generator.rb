module HoboFields

  class MigrationGeneratorError < RuntimeError; end

  class MigrationGenerator

    @ignore_models = []
    @ignore_tables = []

    class << self
      attr_accessor :ignore_models, :ignore_tables
    end

    def self.run(renames={})
      g = MigrationGenerator.new
      g.renames = renames
      g.generate
    end

    def initialize(*args)
      options = args.extract_options!
      @ambiguity_resolver = args.first
      @drops = []
      @renames = nil
      @force_drop = options[:force_drop]
    end

    attr_accessor :renames
    
    def force_drop?; @force_drop end


    def load_rails_models
      if defined? RAILS_ROOT
        Dir["#{RAILS_ROOT}/app/models/**/[a-z0-9_]*.rb"].each do |f|
          _, filename = *f.match(%r{/app/models/([_a-z0-9/]*).rb$})
          filename.camelize.constantize
        end
      end
    end


    # Returns an array of model classes that *directly* extend
    # ActiveRecord::Base, excluding anything in the CGI module
    def table_model_classes
      load_rails_models
      ActiveRecord::Base.send(:subclasses).where.descends_from_active_record?.reject {|c| c.name.starts_with?("CGI::") }
    end


    def self.connection
      ActiveRecord::Base.connection
    end
    def connection; self.class.connection; end


    def self.fix_native_types(types)
      case connection.class.name
      when /mysql/i
        types[:integer][:limit] ||= 11
      end
      types
    end

    def self.native_types
      @native_types ||= fix_native_types connection.native_database_types
    end
    def native_types; self.class.native_types; end

    # Returns an array of model classes and an array of table names
    # that generation needs to take into account
    def models_and_tables
      ignore_model_names = MigrationGenerator.ignore_models.map &it.to_s.underscore
      models = table_model_classes.select { |m| m < HoboFields::ModelExtensions && m.name.underscore.not_in?(ignore_model_names) }
      db_tables = connection.tables - MigrationGenerator.ignore_tables.*.to_s
      [models, db_tables]
    end


    # return a hash of table renames and modifies the passed arrays so
    # that renamed tables are no longer listed as to_create or to_drop
    def extract_table_renames!(to_create, to_drop)
      if force_drop?
        # no renames at all
        {}
        
      elsif renames
        # A hash of table renames has been provided

        to_rename = {}
        renames.each_pair do |old_name, new_name|
          new_name = new_name[:table_name] if new_name.is_a?(Hash)
          next unless new_name

          if to_create.delete(new_name.to_s) && to_drop.delete(old_name.to_s)
            to_rename[old_name.to_s] = new_name.to_s
          else
            raise MigrationGeneratorError, "Invalid table rename specified: #{old_name} => #{new_name}"
          end
        end
        to_rename

      elsif @ambiguity_resolver
        @ambiguity_resolver.extract_renames!(to_create, to_drop, "table")

      else
        raise MigrationGeneratorError, "Unable to resolve migration ambiguities"
      end
    end


    def extract_column_renames!(to_add, to_remove, table_name)
      if force_drop?
        # no renames at all
        {}
        
      elsif renames
        to_rename = {}
        column_renames = renames._?[table_name.to_sym]
        if column_renames
          # A hash of table renames has been provided

          column_renames.each_pair do |old_name, new_name|
            if to_add.delete(new_name.to_s) && to_remove.delete(old_name.to_s)
              to_rename[old_name.to_s] = new_name.to_s
            else
              raise MigrationGeneratorError, "Invalid rename specified: #{old_name} => #{new_name}"
            end
          end
        end
        to_rename

      elsif @ambiguity_resolver
        @ambiguity_resolver.extract_renames!(to_add, to_remove, "column", "#{table_name}.")

      else
        raise MigrationGeneratorError, "Unable to resolve migration ambiguities in table #{table_name}"
      end
    end
    
    
    def always_ignore_tables
      sessions_table = CGI::Session::ActiveRecordStore::Session.table_name if
        defined?(CGI::Session::ActiveRecordStore::Session) &&
        defined?(ActionController::Base) &&
        ActionController::Base.session_store == CGI::Session::ActiveRecordStore
      ['schema_info', 'schema_migrations',  sessions_table].compact
    end


    def generate
      models, db_tables = models_and_tables
      models_by_table_name = models.index_by {|m| m.table_name}
      model_table_names = models.*.table_name

      to_create = model_table_names - db_tables
      to_drop = db_tables - model_table_names - always_ignore_tables
      to_change = model_table_names

      to_rename = extract_table_renames!(to_create, to_drop)

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
        create_table(models_by_table_name[t])
      end * "\n\n"
      undo_creates = to_create.map do |t|
        "drop_table :#{t}"
      end * "\n"

      changes = []
      undo_changes = []
      to_change.each do |t|
        model = models_by_table_name[t]
        table = to_rename.index(t) || model.table_name
        if table.in?(db_tables)
          change, undo = change_table(model, table)
          changes << change
          undo_changes << undo
        end
      end

      up   = [renames, drops, creates, changes].flatten.reject(&:blank?) * "\n\n"
      down = [undo_changes, undo_renames, undo_drops, undo_creates].flatten.reject(&:blank?) * "\n\n"

      [up, down]
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

    def change_table(model, current_table_name)
      new_table_name = model.table_name

      db_columns = model.connection.columns(current_table_name).index_by{|c|c.name} - [model.primary_key]
      model_column_names = model.field_specs.keys.*.to_s
      db_column_names = db_columns.keys.*.to_s

      to_add = model_column_names - db_column_names
      to_remove = db_column_names - model_column_names - [model.primary_key.to_sym]

      to_rename = extract_column_renames!(to_add, to_remove, new_table_name)

      db_column_names -= to_rename.keys
      db_column_names |= to_rename.values
      to_change = db_column_names & model_column_names

      renames = to_rename.map do |old_name, new_name|
        "rename_column :#{new_table_name}, :#{old_name}, :#{new_name}"
      end
      undo_renames = to_rename.map do |old_name, new_name|
        "rename_column :#{new_table_name}, :#{new_name}, :#{old_name}"
      end

      to_add = to_add.sort_by {|c| model.field_specs[c].position }
      adds = to_add.map do |c|
        spec = model.field_specs[c]
        args = [":#{spec.sql_type}"] + format_options(spec.options, spec.sql_type)
        "add_column :#{new_table_name}, :#{c}, #{args * ', '}"
      end
      undo_adds = to_add.map do |c|
        "remove_column :#{new_table_name}, :#{c}"
      end

      removes = to_remove.map do |c|
        "remove_column :#{new_table_name}, :#{c}"
      end
      undo_removes = to_remove.map do |c|
        revert_column(current_table_name, c)
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
          change_spec[:limit]     = spec.limit     unless spec.limit.nil? && col.limit.nil?
          change_spec[:precision] = spec.precision unless spec.precision.nil?
          change_spec[:scale]     = spec.scale     unless spec.scale.nil?
          change_spec[:null]      = spec.null      unless spec.null && col.null
          change_spec[:default]   = spec.default   unless spec.default.nil? && col.default.nil?

          changes << "change_column :#{new_table_name}, :#{c}, " +
            ([":#{spec.sql_type}"] + format_options(change_spec, spec.sql_type, true)).join(", ")
          back = change_column_back(current_table_name, col_name)
          undo_changes << back unless back.blank?
        else
          nil
        end
      end.compact

      [(renames + adds + removes + changes) * "\n",
       (undo_renames + undo_adds + undo_removes + undo_changes) * "\n"]
    end


    def format_options(options, type, changing=false)
      options.map do |k, v|
        unless changing
          next if k == :limit && (type == :decimal || v == native_types[type][:limit])
          next if k == :null && v == true
        end
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

  end

end
