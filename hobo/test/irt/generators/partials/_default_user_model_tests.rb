desc "All files exists"
files_exist? %w[ app/models/user.rb
                 app/models/user.rb
]
test_value_eql? true

desc "User Model injection matches"
file_include? 'app/models/user.rb',
              'hobo_user_model',
              'fields do',
              /name\s+:string/,
              /email_address\s+:email_address/
test_value_eql? true
