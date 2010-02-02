
namespace :hobo do

  desc "Replace commonly used hobo assets with symlinks into the plugin so that they stay up to date"
  task :symlink_assets => :environment do
    
    path_to_generators = HOBO_ROOT.match(%r(vendor/plugins/.*$))[0] + "/rails_generators"
    
    Dir.chdir("#{RAILS_ROOT}/public") do
      Dir.chdir("javascripts") do
        puts "hobo-rapid.js"
        `rm -f hobo-rapid.js`
        `ln -s ../../#{path_to_generators}/hobo_rapid/templates/hobo-rapid.js`
      end

      Dir.chdir("hobothemes") do
        puts "public/hobothemes/clean"
        `rm -rf clean`
        `ln -s ../../#{path_to_generators}/hobo_rapid/templates/themes/clean/public clean`
      end
    end
    
    Dir.chdir("#{RAILS_ROOT}/app/views/taglibs/themes") do
      puts 'taglibs/themes/clean'
      `rm -rf clean`
      `ln -s ../../../../#{path_to_generators}/hobo_rapid/templates/themes/clean/views clean`
    end

  end
  
  desc "Run the DRYML generators to generate taglibs in app/views/taglibs/auto"
  task :generate_taglibs => :environment do
    Dryml::DrymlGenerator.run
  end
  
  desc "Run the standard generators that the hobo command runs."
  task :run_standard_generators do
    exec <<-END
      ruby script/generate hobo --add-routes && \
      ruby script/generate hobo_rapid --import-tags && \
      ruby script/generate hobo_user_model user && \
      ruby script/generate hobo_user_controller user && \
      ruby script/generate hobo_front_controller front --delete-index --add-routes
    END
  end

  desc "Run the standard generators that the hobo command runs with the --invite-only option."
  task :run_invite_only_generators do
    exec <<-END
      ruby script/generate hobo --add-routes && \
      ruby script/generate hobo_rapid --import-tags --invite-only && \
      ruby script/generate hobo_user_model user --invite-only && \
      ruby script/generate hobo_user_controller user --invite-only && \
      ruby script/generate hobo_front_controller front --delete-index --add-routes --invite-only 
    END
  end
end

