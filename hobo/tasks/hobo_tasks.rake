namespace :hobo do

  desc "Replace commonly used hobo assets with symlinks into the plugin so that they stay up to date"
  task :symlink_assets do

    Dir.chdir("#{RAILS_ROOT}/public") do
      Dir.chdir("javascripts") do
        puts "hobo-rapid.js"
        `rm -fi hobo-rapid.js`
        `ln -s ../../vendor/plugins/hobo/rails_generators/hobo_rapid/templates/hobo-rapid.js`
      end

      Dir.chdir("hobothemes") do
        puts "public/hobothemes/clean"
        `rm -rfi clean`
        `ln -s ../../vendor/plugins/hobo/rails_generators/hobo_rapid/templates/themes/clean/public clean`
      end
    end
    
    Dir.chdir("#{RAILS_ROOT}/app/views/taglibs/themes") do
      puts 'taglibs/themes/clean'
      `rm -rfi clean`
      `ln -s ../../../../vendor/plugins/hobo/rails_generators/hobo_rapid/templates/themes/clean/views clean`
    end

  end

end

