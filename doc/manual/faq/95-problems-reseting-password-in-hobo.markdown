# Problems reseting password in hobo

Originally written by Javier on 2011-05-06.

Hi, I'm new in Hobo world, I think it's a great tool for web development, but I need help.
My problem is if I create a new app with Hobo, and use this http://codelikezell.com/using-gmail-with-rails/ to send password reset email it works fine, but I'm working in a existing web app and try to do the same thing for the another app but when I send the email for reset password link I get "LifecycleError in UsersController#forgot_password" error. 
In parameters section I read:
{"page_path"=>"/forgot_password",
 "authenticity_token"=>"tyXsYMr31urJOMpSvoL8VV4H7YSGuNHU7rlYMFJJKhM=",
 "email_address"=>"email@domain.com"}

Where I can star looking for a solution?

Thanks.