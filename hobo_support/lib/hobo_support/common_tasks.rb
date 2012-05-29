require 'hobo_support/module'

module HoboSupport
  CommonTasks = classy_module do

namespace :test do

  desc "Prepare a rails application for testing"
  task :prepare_testapp, :force do |t, args|
    if args.force || !File.directory?(TESTAPP_PATH)
      remove_entry_secure( TESTAPP_PATH, true )
      sh %(#{BIN} new #{TESTAPP_PATH} --skip-wizard --skip-bundle)
      chdir TESTAPP_PATH
      if ENV['HOBODEV']
        rvmrc_path = File.join(ENV['HOBODEV'], '.rvmrc')
        if File.exist?(rvmrc_path)
          puts %(Copying .rvmrc file)
          copy_file rvmrc_path, './.rvmrc'
          sh %(rvm reload) do |ok|
            puts 'rvm command skipped' unless ok
          end
        end
      end
      sh %(bundle install)
      sh %(echo "" >> Gemfile)
      sh %(echo "gem 'irt', :group => :development" >> Gemfile) # to make the bundler happy
      sh %(echo "gem 'therubyracer'" >> Gemfile)
      sh %(echo "" > app/models/.gitignore) # because git reset --hard would rm the dir
      rm %(.gitignore) # we need to reset everything in a testapp
      sh %(git init && git add . && git commit -m "initial commit")
      puts %(The testapp has been created in '#{TESTAPP_PATH}')
    else
      chdir TESTAPP_PATH
      sh %(git add .)
      sh %(git reset --hard -q HEAD)
    end
  end
end

  end
end
