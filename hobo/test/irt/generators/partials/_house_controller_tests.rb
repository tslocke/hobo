desc "All controller files exists"
files_exist? %w( app/controllers/houses_controller.rb app/helpers/houses_helper.rb )

test_value_eql? true

desc "Controller injection matches"
file_include? 'app/controllers/houses_controller.rb',
              'hobo_model_controller',
              'auto_actions :all'

test_value_eql? true
