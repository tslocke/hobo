desc "Run tests and doctests for all components."
task :test_all do |t|
  system "cd hobofields ; rake test:doctest"
  system "cd hobofields ; rake test:unit"
  system "cd hobosupport ; rake test:doctest"
  system "cd hobo ; rake test"
end
