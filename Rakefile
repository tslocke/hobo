desc "Run tests and doctests for all components."
task :test_all do |t|
  puts "There are system tests in http://github.com/tablatom/agility/tree/master"
  puts "and http://github.com/bryanlarsen/hobo-test"
  system("cd hobofields ; rake test:doctest") &&
    system("cd hobofields ; rake test:unit") &&
    system("cd hobosupport ; rake test:doctest") &&
    system("cd hobo ; rake test:doctest") &&
    system("cd hobo ; rake test")
  exit($?.exitstatus)
end
