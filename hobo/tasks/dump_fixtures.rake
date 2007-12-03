namespace :hobo do

  namespace :fixtures do
    
    desc 'Dump a database to yaml fixtures.  Set environment variables DB'
         'and DEST to specify the target database and destination path for the'
         'fixtures.  DB defaults to development and DEST defaults to RAILS_ROOT/'
         'test/fixtures.'

    task :dump => :environment do
      path = ENV['DEST'] || "#{RAILS_ROOT}/test/fixtures"
      db   = ENV['RAILS_ENV']   || 'test'
      
      skip = (ENV['SKIP'] || "").split(",")
      skip << "schema_info"
      
      sql  = 'SELECT * FROM %s'

      ActiveRecord::Base.establish_connection(db)
      ActiveRecord::Base.connection.select_values('show tables').each do |table_name|
        unless skip.include?(table_name)
          fixture_file = "#{path}/#{table_name}.yml"
          old = YAML::load(File.read(fixture_file)) rescue nil

          records = ActiveRecord::Base.connection.select_all(sql % table_name).inject({}) do |hash, record|
            record.each_pair do |k, v| 
              if v.nil?
                record.delete(k)
              elsif (k == "id" or k.ends_with?("_id")) and v =~ /^\d+$/
                record[k] = v.to_i
              end
            end 
            old_pair = old && old.find{|k,v| v["id"] == record["id"]}
            name = old_pair ? old_pair.first : "#{table_name.singularize}_#{record["id"]}"
            hash[name] = record
            hash
          end
          File.open(fixture_file, 'wb') { |file| file.write(records.to_yaml) }
        end
      end
    end

    # ActiveRecord::Base.connection.select_values('show tables')
    # is mysql specific
    # SQLite:  ActiveRecord::Base.connection.select_values('.table')
    # Postgres
    # table_names = ActiveRecord::Base.connection.select_values(<<-end_sql)
    #    SELECT c.relname
    #    FROM pg_class c
    #      LEFT JOIN pg_roles r     ON r.oid = c.relowner
    #      LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
    #    WHERE c.relkind IN ('r','')
    #      AND n.nspname IN ('myappschema', 'public')
    #      AND pg_table_is_visible(c.oid)
    # end_sql

    def fixture_name(table, record)
      model = table.classify.constantize
      name = if table.in?(FIXTURE_NAMES)
               obj = model.find(record[model.primary_key])
               FIXTURE_NAMES[table].call(obj)
             else
               record["name"] || record["title"] || "#{table}_#{record[model.primary_key]}"
             end
      name.gsub(/\W+/, "_").downcase
    end

  end
  
end
