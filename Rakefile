RUBY = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name']).sub(/.*\s.*/m, '"\&"')
RUBYDOCTEST = ENV['RUBYDOCTEST'] || "#{RUBY} `which rubydoctest`"
GEMS_ROOT = File.expand_path('../')

desc "Run tests and doctests for all components."
task :test_all do |t|
  puts "These are a small fraction of the tests available for Hobo.   Run the rest from http://github.com/bryanlarsen/hobo-test-environment"
  system("cd dryml ; #{RUBY} -S rake test") &&
    system("cd hobo_fields ; #{RUBY} -S rake test:doctest") &&
    system("cd hobo_fields ; #{RUBY} -S rake test:unit") &&
    system("cd hobo_support ; #{RUBY} -S rake test:doctest") &&
    system("cd hobo ; #{RUBY} -S rake test:doctest") &&
    system("cd hobo ; #{RUBY} -S rake test")
  exit($?.exitstatus)
end

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files = ['*/lib/**/*.rb', '-', 'hobo/README', 'hobo/CHANGES.txt', 'hobo/LICENSE.txt', 'dryml/README', 'dryml/CHANGES.txt']
end

desc "Build and push or install all the hobo-gems"
task :gems, :action, :force do |t, args|
  unless args.action.match(/^push|install$/)
    puts "Unknown '#{args.action}' action: it must be either 'push' or 'install'."
    exit(1)
  end
  if ! args.force && ! `git status -s`.empty?
    puts <<-EOS.gsub(/^ {6}/, '')
      Rake task aborted: the working tree is dirty!
      If you know what you are doing you can use \`rake gems[#{args.action},force]\`"
    EOS
    exit(1)
  end


  %w[hobo_support hobo_fields dryml hobo].each do |name|
    chdir(File.expand_path("../#{name}", __FILE__)) do
      orig_version = version = File.read('VERSION').strip
    begin
      # add the commit ID to the version, since it might not be the real gem version that will be published
      if args.action == 'install'
        commit_id = `git log -1 --format="%h" HEAD`.strip
        version = "#{orig_version}.#{commit_id}"
        File.open('VERSION', 'w') do |f|
          f.puts version
        end
      end

      gem_name = "#{name}-#{version}.gem"
      sh %(gem build #{name}.gemspec)
      sh %(gem #{args.action} #{gem_name} #{args.action == 'install' ? '--local' : ''})

    ensure
      remove_entry_secure gem_name, true
      if args.action == 'install'
        File.open('VERSION', 'w') do |f|
          f.puts orig_version
        end
      end
    end

    end
  end

  if args.action == 'install'
    puts <<-EOS.gsub(/^ {6}/, '')

      *******************************************************************************
      *                                   NOTICE                                    *
      *******************************************************************************
      * The version id of locally installed hobo gems is comparable to a --pre      *
      * version: i.e. it is alphabetically ordered (not numerically ordered),       *
      * besides it includes the sah1 commit id which is not aphabetically ordered,  *
      * so be sure your application picks the version you really intend to use by   *
      * setting it explicitly in the Gemfile.                                       *
      *******************************************************************************

    EOS
  end

end
