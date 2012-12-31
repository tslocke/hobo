# Make a private Hobo app

Originally written by Tom on 2008-10-28.

This recipe answers [User states when account isn't immediately active](/questions/49-user-states-when-account-isn-t)

This recipe answers [How would you make a Hobo site completely private?](/questions/7-how-would-you-make-a-hobo)

# UPDATE - `--invite-only` added to Hobo

You can now just create your app with

    hobo --invite-only my_app

and you'll get a new Hobo app set up so that only those invited by the admin can have accounts.

That's it : )

---

By a 'private' app, we mean that only logged in users can get access, and there is no public sign-up facility.

This recipe is a work in progress.

# Require all users to be logged in

Very easy - just add the following `before_filter` to `ApplicationController`:

    class ApplicationController < ActionController::Base
      ...
      before_filter :login_required
    end
{: .ruby}

Note that this prevents access to the entire site to users that are not logged in. That sounds like a problem - how will the user even visit the login page? Fear not - Hobo's user controller declared `skip_before_filter :login_required` for the login action and a few others

# Prevent signup

Also easy! Your generated user model has the following lifecycle declaration:

    lifecycle do

      initial_state :active

      create :anybody, :signup, 
             :params => [:username, :email_address, :password, :password_confirmation],
             :become => :active, :if => proc {|_, u| u.guest?}

      transition :nobody, :request_password_reset, { :active => :active }, :new_key => true do
        UserMailer.deliver_forgot_password(self, lifecycle.key)
      end

      transition :with_key, :reset_password, { :active => :active }, 
                 :update => [ :password, :password_confirmation ]

    end
{: .ruby}

So - just delete the `:signup` creator, so you're left with

    lifecycle do

      initial_state :active

      transition :nobody, :request_password_reset, { :active => :active }, :new_key => true do
        UserMailer.deliver_forgot_password(self, lifecycle.key)
      end

      transition :with_key, :reset_password, { :active => :active }, 
                 :update => [ :password, :password_confirmation ]

    end
{: .ruby}

That's it. The `<account-nav>` tag tests for the presence of the signup route, which is now gone, so the "sign up" link will be gone too.

