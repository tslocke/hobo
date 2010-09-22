require 'rails/generators/migration'
require 'rails/generators/active_record'
require 'generators/hobo_support/thor_shell'

module Hobo
  class MigrationGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    argument :name, :type => :string, :optional => true

    include Rails::Generators::Migration
    include Generators::HoboSupport::ThorShell

    # the Rails::Generators::Migration.next_migration_number gives a NotImplementedError
    # in Rails 3.0.0.beta4, so we need to implement the logic of ActiveRecord.
    # For other ORMs we will wait for the rails implementation
    # see http://groups.google.com/group/rubyonrails-talk/browse_thread/thread/a507ce419076cda2
    def self.next_migration_number(dirname)
      ActiveRecord::Generators::Base.next_migration_number dirname
    end

    def self.banner
      "rails generate hobo:migration #{self.arguments.map(&:usage).join(' ')} [options]"
    end

    class_option :drop,
                 :aliases => '-d',
                 :type => :boolean,
                 :desc => "Don't prompt with 'drop or rename' - just drop everything"

    class_option :default_name,
                 :aliases => '-n',
                 :type => :boolean,
                 :desc => "Don't prompt for a migration name - just pick one"

    class_option :generate,
                 :aliases => '-g',
                 :type => :boolean,
                 :desc => "Don't prompt for action - generate the migration"

    class_option :migrate,
                 :aliases => '-m',
                 :type => :boolean,
                 :desc => "Don't prompt for action - generate and migrate"

    def migrate
      return if migrations_pending?

      generator = Generators::Hobo::Migration::Migrator.new(lambda{|c,d,k,p| extract_renames!(c,d,k,p)})
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
               choose("\nWhat now: [g]enerate migration, generate and [m]igrate now or [c]ancel?", /^(g|m|c)$/)

      if action != 'c'
        if name.blank? && !options[:default_name]
          final_migration_name = choose("\nMigration filename: [<enter>=#{migration_name}|<custom_name>]:", /^[a-z0-9_ ]*$/, migration_name).strip.gsub(' ', '_')
        end
        final_migration_name = migration_name if final_migration_name.blank?

        up.gsub!("\n", "\n    ")
        up.gsub!(/ +\n/, "\n")
        down.gsub!("\n", "\n    ")
        down.gsub!(/ +\n/, "\n")

        @up = up
        @down = down
        @migration_class_name = final_migration_name.camelize

        migration_template 'migration.rb.erb', "db/migrate/#{final_migration_name.underscore}.rb"
        rake('db:migrate') if action == 'm'
      end
    rescue HoboFields::Model::FieldSpec::UnknownSqlTypeError => e
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
      to_rename = {}

      unless options[:drop]

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
      end
      to_rename
    end

    def migration_name
      name || Generators::Hobo::Migration::Migrator.default_migration_name
    end

  end
end

