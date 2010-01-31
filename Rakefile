RUBY = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name']).sub(/.*\s.*/m, '"\&"')
RUBYDOCTEST = ENV['RUBYDOCTEST'] || "#{RUBY} `which rubydoctest`"

desc "Run tests and doctests for all components."
task :test_all do |t|
  puts "These are a small fraction of the tests available for Hobo.   Run the rest from http://github.com/bryanlarsen/hobo-test-environment"
  system("cd dryml ; #{RUBY} -S rake test") &&
    system("cd hobofields ; #{RUBY} -S rake test:doctest") &&
    system("cd hobofields ; #{RUBY} -S rake test:unit") &&
    system("cd hobosupport ; #{RUBY} -S rake test:doctest") &&
    system("cd hobo ; #{RUBY} -S rake test:doctest") &&
    system("cd hobo ; #{RUBY} -S rake test")
  exit($?.exitstatus)
end

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files = ['*/lib/**/*.rb', '-', 'hobo/README', 'hobo/CHANGES.txt', 'hobo/LICENSE.txt', 'dryml/README', 'dryml/CHANGES.txt']
end
