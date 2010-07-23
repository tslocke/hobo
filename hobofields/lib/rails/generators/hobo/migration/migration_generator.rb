require 'rails/generators/migration'
require 'rails/generators/active_record'

module Hobo
  class MigrationGenerator < Rails::Generators::Base

    include Rails::Generators::Migration

    # the Rails::Generators::Migration.next_migration_number gives a NotImplementedError
    # in Rails 3.0.0.beta4, so we need to implement the logic of ActiveRecord.
    # For other ORMs we will wait for the rails implementation
    # see http://groups.google.com/group/rubyonrails-talk/browse_thread/thread/a507ce419076cda2
    def self.next_migration_number(dirname)
     ActiveRecord::Generators::Base.next_migration_number dirname
    end

    source_root File.expand_path('../templates', __FILE__)

    argument :migration_name,
             :type => :string,
             :default => HoboFields::MigrationGenerator.default_migration_name

    class_option :force_drop,
                 :type => :boolean,
                 :default => false,
                 :desc => "Don't prompt with 'drop or rename' - just drop everything"

    class_option :default_name,
                 :type => :boolean,
                 :default => false,
                 :desc => "Don't prompt for a migration name - just pick one"

    class_option :generate,
                 :type => :boolean,
                 :default => false,
                 :desc => "Don't prompt for action - generate the migration"

    class_option :migrate,
                 :type => :boolean,
                 :default => false,
                 :desc => "Don't prompt for action - generate and migrate"

    def migrate
      return if migrations_pending?

      generator = HoboFields::MigrationGenerator.new(lambda{|c,d,k,p| extract_renames!(c,d,k,p)})
      up, down = generator.generate

      if up.blank?
        say "Database and models match -- nothing to change"
        return
      end

      say "\n---------- Up Migration ----------"
      say up
      say "----------------------------------"

      say "\n---------- Down Migration --------"
      say down
      say "----------------------------------"

      action = options[:generate] && 'g' ||
               options[:migrate] && 'm' ||
               choose("What now: [g]enerate migration, generate and [m]igrate now or [c]ancel?", /^(g|m|c)$/)

      if action != 'c'
        say "\nMigration filename:"
        say "(you can type spaces instead of '_' -- every little helps)"
        final_migration_name = choose("Filename [#{migration_name}]:", /^[a-z0-9_ ]*$/).strip.gsub(' ', '_') unless options[:default_name]
        final_migration_name = migration_name if final_migration_name.blank?

        at_exit { rake_migrate } if action == 'm'

        up.gsub!("\n", "\n    ")
        up.gsub!(/ +\n/, "\n")
        down.gsub!("\n", "\n    ")
        down.gsub!(/ +\n/, "\n")

        @up = up
        @down = down
        @migration_class_name = final_migration_name.camelize

        migration_template 'migration.rb.erb', "db/migrate/#{final_migration_name.underscore}.rb"
      end
    rescue HoboFields::FieldSpec::UnknownSqlTypeError => e
      say "Invalid field type: #{e}"
    end

  private

    def migrations_pending?
      pending_migrations = ActiveRecord::Migrator.new(:up, 'db/migrate').pending_migrations

      if pending_migrations.any?
        say "You have #{pending_migrations.size} pending migration#{'s' if pending_migrations.size > 1}:"
        pending_migrations.each do |pending_migration|
          say '  %4d %s' % [pending_migration.version, pending_migration.name]
        end
        true
      else
        false
      end
    end

    def extract_renames!(to_create, to_drop, kind_str, name_prefix="")
      return {} if options[:force_drop]

      to_rename = {}
      rename_to_choices = to_create
      to_drop.dup.each do |t|
        while true
          if rename_to_choices.empty?
            say "\nCONFIRM DROP! #{kind_str} #{name_prefix}#{t}"
            resp = ask("Enter 'drop #{t}' to confirm or press enter to keep:")
            if resp.strip == "drop " + t.to_s
              break
            elsif resp.strip.empty?
              to_drop.delete(t)
              break
            else
              next
            end
          else
            say "\nDROP, RENAME or KEEP?: #{kind_str} #{name_prefix}#{t}"
            say "Rename choices: #{to_create * ', '}"
            resp = ask "Enter either 'drop #{t}' or one of the rename choices or press enter to keep:"
            resp.strip!

            if resp == "drop " + t
              # Leave things as they are
              break
            else
              resp.gsub!(' ', '_')
              to_drop.delete(t)
              if resp.in?(rename_to_choices)
                to_rename[t] = resp
                to_create.delete(resp)
                rename_to_choices.delete(resp)
                break
              elsif resp.empty?
                break
              else
                next
              end
            end
          end
        end
      end
      to_rename
    end


    def choose(prompt, format)
      choice = ask prompt
      if choice =~ format
        choice
      else
        choose prompt, format
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
end

