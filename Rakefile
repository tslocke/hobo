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
  unless args.action == 'push' || args.action == 'install'
    puts "Unknown '#{args.action}' action: it must be either 'push' or 'install'."
    exit
  end
  if ! args.force && ! `git status -s`.empty?
    puts 'Rake task aborted: the working tree is dirty!'
    exit
  end

  %w[hobo_support hobo_fields dryml hobo].each do |name|
    chdir File.expand_path("../#{name}", __FILE__)
    version = File.read('VERSION').strip
    gem_name = "#{name}-#{version}.gem"
    sh %(gem build #{name}.gemspec)
    sh %(gem #{args.action} #{gem_name})
    rm gem_name
  end
end
