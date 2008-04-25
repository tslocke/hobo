require File.dirname(__FILE__) + '/../../lib/hobofields'
class HoboMigrationGenerator < Rails::Generator::Base

  def initialize(runtime_args, runtime_options = {})
    super
    @migration_name = runtime_args.first || begin
                                              i = Dir["#{RAILS_ROOT}/db/migrate/*hobo_migration*"].length
                                              "hobo_migration_#{i+1}"
                                            end
  end
  
  def manifest
    generator = HoboFields::MigrationGenerator.new(self)
    up, down = generator.generate

    if up.blank?
      puts "Database and models match -- nothing to change"
      return record {|m| } 
    end
      
    puts "\n---------- Up Migration ----------", up, "----------------------------------"
    puts "\n---------- Down Migration --------", down, "----------------------------------"
    
    action = input("What now: [g]enerate migration, generate and [m]igrate now or [c]ancel?", %w(g m c))

    if action == 'c'
      # record nothing to keep the generator happy
      record {|m| }
    else
      puts "\nMigration filename:", "(you can type spaces instead of '_' -- every little helps)"
      migration_name = input("Filename [#@migration_name]:").strip.gsub(' ', '_')
      migration_name = @migration_name if migration_name.blank?
      
      at_exit { rake_migrate } if action == 'm'
      
      up.gsub!("\n", "\n    ")
      down.gsub!("\n", "\n    ")

      record do |m|
        m.migration_template 'migration.rb', 'db/migrate', 
                             :assigns => { :up => up, :down => down, :migration_name => migration_name.camelize }, 
                             :migration_file_name => migration_name
      end
    end
  rescue HoboFields::FieldSpec::UnknownSqlTypeError => e
    puts "Invalid field type: #{e}"
    record {|m| }
  end
  
  
  def extract_renames!(to_create, to_drop, kind_str, name_prefix="")
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
  
  def rake_migrate
    if RUBY_PLATFORM =~ /mswin32/
      system "rake.bat db:migrate"
    else
      system "rake db:migrate"
    end
  end
  
end

