desc "All user controller files exists"
files_exist? %w[ app/controllers/users_controller.rb
                 app/helpers/users_helper.rb
                 test/unit/helpers/users_helper_test.rb
                 test/functional/users_controller_test.rb
]
test_value_eql? true


desc "User controller injection matches"
file_include? 'app/controllers/users_controller.rb',
            'class UsersController < ApplicationController',
            'hobo_user_controller',
            'auto_actions :all, :except => [ :index, :new, :create ]'
test_value_eql? true

