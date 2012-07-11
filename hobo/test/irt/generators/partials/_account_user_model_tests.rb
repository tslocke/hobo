desc "Account Model files exist"
files_exist? %w(app/models/account.rb)
test_value_eql? true

desc "Account Model injection matches"
file_include? 'app/models/account.rb',
              'hobo_user_model',
              'fields do',
              /name\s+\:string/ ,
              /email_address\s+\:email_address/
test_value_eql? true
