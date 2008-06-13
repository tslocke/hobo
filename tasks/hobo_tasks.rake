namespace :hobo do

  desc "Replace commonly used hobo assets with symlinks into the plugin so that they stay up to date"
  task :symlink_assets do

    Dir.chdir("#{RAILS_ROOT}/public") do
      Dir.chdir("javascripts") do
        puts "hobo-rapid.js"
        `rm -f hobo-rapid.js`
        `ln -s ../../vendor/plugins/hobo/rails_generators/hobo_rapid/templates/hobo-rapid.js`
      end
      
      Dir.chdir("hobothemes") do       
        puts "hobothemes/clean"
        `rm -f clean`
        `ln -s ../../vendor/plugins/hobo/rails_generators/hobo_rapid/templates/themes/clean/public clean`
      end
    end

  end

end

