RUBY = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name']).sub(/.*\s.*/m, '"\&"')
RUBYDOCTEST = ENV['RUBYDOCTEST'] || "#{RUBY} `which rubydoctest`"
if defined?(Bundler)
  RAKE = "bundle exec rake"
else
  RAKE = "#{RUBY} -S rake"
end

desc "Run tests and doctests for all components."
task :test_all do |t|
  puts "These are a small fraction of the tests available for Hobo.   Run the rest from http://github.com/tablatom/agility and http://github.com/tablatom/hobo.git"
  system("cd hobofields ; #{RAKE} test:doctest") &&
    system("cd hobofields ; #{RAKE} test:unit") &&
    system("cd hobosupport ; #{RAKE} test:doctest") &&
    system("cd hobo ; #{RAKE} test:doctest") &&
    system("cd hobo ; #{RAKE} test")
  exit($?.exitstatus)
end
