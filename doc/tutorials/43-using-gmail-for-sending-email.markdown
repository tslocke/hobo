# Using GMail for Sending Email

Originally written by baldrailers on 2010-03-28.

If you enabled **GoogleApps** in your Domain. You might want to take advantage of sending email using **Gmail**. You just need to do the following simple steps. This is very useful specially when your using **--invite-only** option when creating your hobo application.

Let's start rolling. You need to install the following gem. If your using heroku as your staging server or even production server you might want to include this on your **.gems** file:

Install the gem in your local machine: 
    sudo gem install tlsmail

Again if your using heroku, add the following line in your .gems file:
    tlsmail --version '>= 0.0.1' 


Now that you have the gem in place it's time to add other configurations:

Your **environment.rb** should look like this:

    Rails::Initializer.run do |config|
        config.gem "tlsmail"
    ...
    end
    Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)


Add the following lines in your **environments/development.rb** or **environments/production.rb**:

    config.action_mailer.delivery_method = :smtp
        config.action_mailer.smtp_settings = {
        :address => "smtp.gmail.com",
        :port => "25",
        :domain => "your_domain.com",
        :user_name => "your_login@your_domain.com",
        :password => "your_password",
        :authentication => :login
    }



That should be it. If you do:

    git push heroku master 


It will automatically install the gem in your heroku instance, then you should be able to send invites or better yet send email from your hobo application.

Thanks to: **http://codelikezell.com/using-gmail-with-rails/** for this guide.

