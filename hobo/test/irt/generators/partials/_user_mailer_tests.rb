
desc "User Mailer files exist"
files_exist? %w[ app/mailers/user_mailer.rb
                 app/views/user_mailer/forgot_password.erb
]
test_value_eql? true

desc "user_mailer.rb file content"
file_include? 'app/mailers/user_mailer.rb',
              'class UserMailer'
test_value_eql? true

desc "forgot_password.erb file content"
file_include? 'app/views/user_mailer/forgot_password.erb',
             '<%= @user %>',
             'If you have forgotten'
test_value_eql? true
