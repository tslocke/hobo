RUBY = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name']).sub(/.*\s.*/m, '"\&"')
RUBYDOCTEST = ENV['RUBYDOCTEST'] || "#{RUBY} `which rubydoctest`"

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

namespace :gems do
  desc "Build and push all the hobo-gems"
  task :push do |t|
    unless `git status -s`.empty?
      puts 'Rake task aborted: the working tree is dirty!'
      exit
    end

    %w[hobo_support hobo_fields dryml hobo].each do |name|
      chdir File.expand_path("../#{name}", __FILE__)
      version = File.read('VERSION').strip
      gem_name = "#{name}-#{version}.gem"
      sh %(gem build #{name}.gemspec)
      sh %(gem push #{gem_name})
      rm gem_name
    end

  end
end
