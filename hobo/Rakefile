require 'rake'
require 'rake/rdoctask'
require 'rake/testtask'

load "tasks/generate_tag_reference.rb"

desc 'Default: run specs.'
task :default => :spec

desc 'Generate documentation for the Hobo plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Hobo'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'echoe'

Echoe.new('hobo') do |p|
  p.author  = "Tom Locke"
  p.email   = "tom@tomlocke.com"
  p.summary = "The web app builder for Rails"
  p.url     = "http://hobocentral.net/"
  p.project = "hobo"

  p.changelog = "CHANGES.txt"
  p.version   = "0.7.5"

  p.dependencies = [
    'hobosupport >=0.7.5',
    'hobofields >=0.7.5',
    'rails =2.0.2',
    'will_paginate >= 2.2.1']
end




# --- RSpec --- #

# In rails 1.2, plugins aren't available in the path until they're loaded.
# Check to see if the rspec plugin is installed first and require
# it if it is.  If not, use the gem version.
PLUGIN_DIR = File.dirname(__FILE__)

rspec_base = File.expand_path(PLUGIN_DIR + '/spec/rails_root/vendor/plugins/rspec/lib')
$LOAD_PATH.unshift(rspec_base) if File.exist?(rspec_base)
require '../hobo_spec/rails_root/vendor/plugins/rspec/lib/spec/rake/spectask'
require '../hobo_spec/rails_root/vendor/plugins/rspec/lib/spec/translator'

spec_prereq = :noop # File.exist?(File.join(PLUGIN_DIR, 'config', 'database.yml')) ? "db:test:prepare" : :noop
task :noop do
end

task :stats => "spec:statsetup"

SPEC_HOME = "#{PLUGIN_DIR}/../hobo_spec"

desc "Run all specs in spec directory (excluding plugin specs)"
Spec::Rake::SpecTask.new(:spec => spec_prereq) do |t|
  t.spec_opts = ['--options', "\"#{SPEC_HOME}/spec.opts\""]
  t.spec_files = FileList["#{SPEC_HOME}/unit/**/*_spec.rb"]
end

namespace :spec do
  desc "Run all specs in spec directory with RCov (excluding plugin specs)"
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_opts = ['--options', "\"#{SPEC_HOME}/spec.opts\""]
    t.spec_files = FileList["#{SPEC_HOME}/unit/**/*_spec.rb"]
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec', '--rails']
  end
  
  desc "Print Specdoc for all specs (excluding plugin specs)"
  Spec::Rake::SpecTask.new(:doc) do |t|
    t.spec_opts = ["--format", "specdoc", "--dry-run"]
    t.spec_files = FileList["#{SPEC_HOME}/unit/**/*_spec.rb"]
  end

  [:models, :controllers, :views, :helpers].each do |sub|
    desc "Run the specs under spec/#{sub}"
    Spec::Rake::SpecTask.new(sub => spec_prereq) do |t|
      t.spec_opts = ['--options', "\"#{SPEC_HOME}/spec.opts\""]
      t.spec_files = FileList["#{SPEC_HOME}/#{sub}/**/*_spec.rb"]
    end
  end
  
  # Setup specs for stats
  task :statsetup do
    require 'code_statistics'
    ::STATS_DIRECTORIES << %w(Model\ specs spec/models)
    ::STATS_DIRECTORIES << %w(View\ specs spec/views)
    ::STATS_DIRECTORIES << %w(Controller\ specs spec/controllers)
    ::STATS_DIRECTORIES << %w(Helper\ specs spec/views)
    ::CodeStatistics::TEST_TYPES << "Model specs"
    ::CodeStatistics::TEST_TYPES << "View specs"
    ::CodeStatistics::TEST_TYPES << "Controller specs"
    ::CodeStatistics::TEST_TYPES << "Helper specs"
    ::STATS_DIRECTORIES.delete_if {|a| a[0] =~ /test/}
  end

  namespace :db do
    namespace :fixtures do
      desc "Load fixtures (from spec/fixtures) into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
      task :load => :environment do
        require 'active_record/fixtures'
        ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
        (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(SPEC_HOME, 'fixtures', '*.{yml,csv}'))).each do |fixture_file|
          Fixtures.create_fixtures("#{SPEC_HOME}/fixtures", File.basename(fixture_file, '.*'))
        end
      end
    end
  end
end
