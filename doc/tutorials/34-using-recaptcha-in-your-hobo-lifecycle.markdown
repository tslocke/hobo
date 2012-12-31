# Using recaptcha in your Hobo Lifecycle

Originally written by RitchieY on 2009-08-06.

The easiest way avoid having automated spam-bots creating zillions of fake accounts in your application is to put a [captcha](http://en.wikipedia.org/wiki/Captcha) on the signup page. [Recaptcha](http://recaptcha.net/) is a fantastically cool one because it:

 * Is a free service
 * Uses the responses to OCR books
 * Has an easy to use [Rails plugin](http://ambethia.com/recaptcha/files/README_rdoc.html)

This is how to add this functionality to a Hobo lifecycle event (create or transition). We'll use the 'signup' create from the [Agility tutorial](http://cookbook.hobocentral.net/tutorials/agility) as an example.

 - Install the recaptcha plugin:

        script/plugin install git://github.com/ambethia/recaptcha

 - Sign up to [Recaptcha](http://recaptcha.net) and generate the keys for your site.

 - Add the keys you've generated to your environment.rb:

        ENV['RECAPTCHA_PUBLIC_KEY'] = 'REPLACE-WITH-YOUR-PUBLIC-KEY'
        ENV['RECAPTCHA_PRIVATE_KEY'] = 'REPLACE-WITH-YOUR-PRIVATE-KEY'

 - In application.dryml extend the form tag for the lifecycle event that you're protecting. For the signup create event, that would look like:

        <extend tag="signup-form" for="User">
          <old-signup-form merge>
            <after-field-list:>
              <%= recaptcha_tags %>
            </after-field-list:>
          </old-signup-form>
        </extend>

    The `recaptcha_tags` provides all the HTML needed to display the Recaptcha dialog. Here we're adding it  _immediately after_ the other form fields. At this point you should be able to refresh the page and the Captcha should display. The result of the Captcha is ignored though. Nothing is protected.

 - In the controller for the model (eg users_controller.rb), add (or modify) the 'do_' method for the lifecycle action to verify the captcha prior to the actual hobo action being invoked. For signup, this should look something like this:

          def do_signup
           unless verify_recaptcha
              flash[:error] = "The Captcha words you entered weren't right."
              redirect_to :back
              return
            end
            hobo_do_signup
            end
          end


Try it out, your lifecycle event should now be protected by a Captcha.

You may have noticed that we didn't really do anything lifecycle specific in here. You could use the same technique described to Captcha protect any form. I just chose lifecycles because they were a common case.

