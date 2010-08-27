desc "All files exists"
files_exist? %w[ app/models/user.rb
                 app/models/user.rb
                 test/unit/user_test.rb
                 test/fixtures/users.yml
                 app/viewhints/user_hints.rb
]
test_value_eql? true

desc "User Model injection matches"
file_include? 'app/models/user.rb',
              'hobo_user_model',
              'fields do',
              /name\s+:string/,
              /email_address\s+:email_address/
test_value_eql? true

desc "Hint content matches"
file_include? 'app/viewhints/user_hints.rb',
            'class UserHints'
test_value_eql? true
