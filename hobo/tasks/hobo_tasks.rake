namespace :hobo do

  desc "Replace commonly used hobo assets with symlinks into the plugin so that they stay up to date"
  task :symlink_assets do
    
    Dir.chdir(RAILS_ROOT) do
      Dir.chdir("public/javascripts") do 
        puts "hobo-rapid.js"
        `rm -f hobo-rapid.js`
        `ln -s ../../vendor/plugins/hobo/generators/hobo_rapid/templates/hobo-rapid.js`
      end
    end
    
  end
  
end
  
