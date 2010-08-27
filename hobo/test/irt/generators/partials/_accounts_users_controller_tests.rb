desc "All controller files exists"
files_exist? %w[ app/controllers/accounts_controller.rb
                 app/helpers/accounts_helper.rb
                 test/unit/helpers/accounts_helper_test.rb
                 test/functional/accounts_controller_test.rb
]
test_value_eql? true


desc "Controller injection matches"
file_include? 'app/controllers/accounts_controller.rb',
              'class AccountsController < ApplicationController',
              'hobo_user_controller',
              'auto_actions :all, :except => [ :index, :new, :create ]'
test_value_eql? true
