require 'hobo_support/module'
module HoboSupport
  CommonTasks = classy_module do

namespace :test do
  desc "Run the irt tests"
  task :irt => :prepare_testapp do |t|
    chdir TESTAPP_PATH
    sh %(irt #{File.expand_path('.',GEM_ROOT)})
  end

  desc "Prepare a rails application for testing"
  task :prepare_testapp, :force do |t, args|
    if args.force || !File.directory?(TESTAPP_PATH)
      remove_entry_secure( TESTAPP_PATH, true )
    #  hobodev = %(HOBODEV=#{ENV["HOBODEV"]}) if ENV["HOBODEV"]
    #  sh %(export #{hobodev})
      sh %(#{BIN} new #{TESTAPP_PATH} --skip-wizard)
      chdir TESTAPP_PATH
      sh %(echo "gem 'irt', :group => :console" >> Gemfile) # to make the bundler happy
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
