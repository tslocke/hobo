require 'echoe'

namespace "test" do
  desc "Run the doctests"
  task :doctest do |t|
    exit(1) if !system("rubydoctest test/*.rdoctest")
  end

  desc "Run the unit tests"
  task :unit do |t|
    Dir["test/test_*.rb"].each do |f|
      exit(1) if !system("ruby #{f}")
    end
  end
end

Echoe.new('hobofields') do |p|
  p.author  = "Tom Locke"
  p.email   = "tom@tomlocke.com"
  p.summary = "Rich field types and migration generator for Rails"
  p.url     = "http://hobocentral.net/hobofields"
  p.project = "hobo"

  p.changelog = "CHANGES.txt"
  p.version   = "0.8.7"

  p.dependencies = ['hobosupport =0.8.7', 'rails >=2.2.2']
  p.development_dependencies = []
end

