RUBY = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name']).sub(/.*\s.*/m, '"\&"')
RUBYDOCTEST = ENV['RUBYDOCTEST'] || "#{RUBY} `which rubydoctest`"

desc "Run tests and doctests for all components."
task :test_all do |t|
  puts "There are system tests in http://github.com/tablatom/agility/tree/master"
  puts "and http://github.com/bryanlarsen/hobo-test"
  system("cd hobofields ; #{RUBY} -S rake test:doctest") &&
    system("cd hobofields ; #{RUBY} -S rake test:unit") &&
    system("cd hobosupport ; #{RUBY} -S rake test:doctest") &&
    system("cd hobo ; #{RUBY} -S rake test:doctest") &&
    system("cd hobo ; #{RUBY} -S rake test")
  exit($?.exitstatus)
end
