require 'fileutils'
require 'tmpdir'

module HoboSupport
  module Command
    class << self

      def run(gem, version=nil)
        version ||= File.read(File.expand_path('../../../VERSION', __FILE__)).strip
        is_hobo = gem == :hobo
        puts "#{gem.to_s.capitalize} Command Line Interface #{version}"

        banner = %(
Usage:
  hobo new <app_name> [rails_options]          Creates a new Hobo Application
  hobo generate|g <generator> [ARGS] [options] Fires the hobo:<generator>
  hobo destroy <generator> [ARGS] [options]    Tries to undo generated code
  hobo --help|-h                               This help screen

Dev Notes:
  Set the HOBODEV ENV variable to your local hobo git-repository path
  in order to use your local dev version instead of the installed gem.

)

        # for hobo developers only
        setup_wizard = true

        command = ARGV.shift

        case command

        when nil
          puts "\nThe command is missing!\n"
          puts banner
          exit

        when /^--help|-h$/
          puts banner
          exit

        when 'new'
          app_name = ARGV.shift
          if is_hobo && ARGV.first =~ /^--skip-wizard$/
            setup_wizard = false
            ARGV.shift
          end
          if app_name.nil?
            puts "\nThe application name is missing!\n"
            puts banner
            exit
          end
          template_path = File.join Dir.tmpdir, "hobo_app_template"
          File.open(template_path, 'w') do |file|
            if ENV["HOBODEV"]
              dev_root = File.expand_path ENV["HOBODEV"], FileUtils.pwd
              file.puts %(
        $:.unshift '#{dev_root}/hobo_support/lib'
        gem 'hobo_support', :path => '#{dev_root}/hobo_support'
        gem 'hobo_fields', :path => '#{dev_root}/hobo_fields'
        )
              if is_hobo
                file.puts %(
        gem 'dryml', :path => '#{dev_root}/dryml'
        gem 'hobo', :path => '#{dev_root}/hobo'
        )
              end
            else
              file.puts "gem '#{gem}', '>= #{version}'"
            end
            if is_hobo && setup_wizard
              file.puts %(
        require 'generators/hobo_support/thor_shell'
        extend Generators::HoboSupport::ThorShell

        say_title "Hobo Setup Wizard"
        if yes_no?("Do you want to start the Setup Wizard now?
(Choose 'no' if you need to manually customize any file before running the Wizard.
You can rerun it at any time with `hobo g setup_wizard` from the application root dir.)")
          exec 'rails g hobo:setup_wizard --no-main-title'
        else
          say "Please, remember to run `hobo g setup_wizard` from the application root dir, in order to complete the Setup.", Thor::Shell::Color::YELLOW
        end
        )
            end
          end
          puts "Generating Rails infrastructure..."
          system "rails new #{app_name} #{ARGV * ' '} -m #{template_path}"
          File.delete template_path

        when /^(g|generate|destroy)$/
          cmd = $1
          if ARGV.empty?
            puts "\nThe generator name is missing!\n"
            puts banner
          else
            if ARGV.first =~ /^hobo:(\w+)$/
              puts "NOTICE: You can omit the 'hobo' namespace: e.g. `hobo #{cmd} #{$1} #{ARGV[1..-1] * ' '}`"
            end
            system "rails #{cmd} hobo:#{ARGV * ' '}"
          end

        else
          puts "\n  => '#{command}' is an unknown command!\n"
          puts banner
        end

      end

    end
  end
end
