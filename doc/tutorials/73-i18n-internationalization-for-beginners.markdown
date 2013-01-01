# I18n Internationalization for beginners

Originally written by txinto on 2011-09-06.

This recipe answers [Definitive guide to multi-language website (I18n)](/manual/faq/97-definitive-guide-to-multi-language-website)

#Step 1:

Create a new Hobo app (we are using Hobo 1.3 RC for this tutorial)

    > hobo new i18ntest


(usual options in wizard, assuming you don't rename the user model name)
When defining locales, add the needed ones: en es fr de

    > cd i18ntest

#Step 2:

Create a UserLocale class to store the available locales

    > hobo g resource UserLocale
    ...
    > edit app/models/user_locale.rb

    fields do
        +name :string, :required, :unique, :limit => 5+
        timestamps
    end
    +has_many :users+

    > edit app/models/user.rb

    +belongs_to :user_locale+

    > hobo g migration
    ...
    > rails server

#Step 3:

Signup as administrator and add some user locales: en es de fr

    > edit app/controllers/user_locales_controller.rb


      -auto_actions :all-
      +auto_actions :all, :except => :index+


#Step 4:

Edit your user and select the correct locale

(note that the field list will show something like `"	<a class="user_locale-link" href="/user_locales/1-en"><span class="view user-locale-name ">en</span></a>". ` Is it probably a bug?

#Step 5:

Add some information in the page footer to help you understanding the process.

    > edit app/views/taglibs/application.dryml


    <def tag="user-lang">
      <%= 
            if current_user.signed_up?
              current_user.user_locale 
            else
              ""
            end
          %>
    </def>

    <extend tag="page">
      <old-page merge>
        <footer:>
          <br/>User: <%= current_user %>
          <br/>Locale: <%= I18n.locale %>
          <br/>Params Locale: <%= params[:locale] %>
          <br/>User Locale: <user-lang/>
          <br/>Default Locale: <%= I18n.default_locale %>
        </footer:>
      </old-page>
    </extend>

This will add the information about the locale variables.  Our precedence will be: params > user > default.  That is: if there exist a ?param=xx URL parameter, it will be the locale of the page to be shown.  If not, then the page will take the current_user.user_locale as locale.  If the current_user is not logged or has no locale set, then the default locale of the application will be used.

#Step 6:

Configure the I18n for the application
    
    > edit config/application.rb


uncomment and tune:

     -# config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]-
     -# config.i18n.default_locale = :de-

     +config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]+
     +config.i18n.default_locale = :en+
    
    > edit apps/controllers/application_controller.rb

      before_filter :set_locale

      def set_locale
        if (params[:locale])
          I18n.locale = params[:locale]
        else if (current_user.signed_up?)
            I18n.locale = current_user.user_locale.to_s
          else
            I18n.locale=I18n.default_locale
          end
        end 
      end

    =begin
      def default_url_options(options={})
        logger.debug "default_url_options is passed options: #{options.inspect}\n"
        { :locale => I18n.locale }
      end
    =end  

Please note that the =begin and =end code will only work fine in the production mode.  The development fast user switcher will fail if you activate this, so we will not uncomment this until the problem is fixed.

#Step 7:

The application must be restarted in order to allow this configuration to take effect.

#Step 8:

Add the user_locale field to the signup page.


    > edit apps/models/users


        create :signup, :available_to => "Guest",
               -:params => [:name, :email_address, :password, :password_confirmation],-
               +:params => [:name, :email_address, :password, :password_confirmation, :user_locale],+
               :become => :active

      def update_permitted?
        acting_user.administrator? ||
          (acting_user == self && only_changed?(:email_address, :crypted_password,
                                                -:current_password, :password, :password_confirmation))-
                                               +:current_password, :password, :password_confirmation,:user_locale))+

      end



#Step 9:

Test the locale preferences are working
Create a new user and set a different locale for him (f.i. 'en' for admin and 'es' for the new user).

Use the development fast user switcher to switch between the useres and see how this change the language the Hobo app is using.

#Step 10:

Activate the default_url_options to test the URL param method.

    > edit apps/controllers/application_controller.rb

     -=begin-
     +#=begin+
      def default_url_options(options={})
        logger.debug "default_url_options is passed options: #{options.inspect}\n"
        { :locale => I18n.locale }
      end
     -=end-  
     +#=end+

#Step 11:

Test the URL params work.

Go to admin user, and go to home.  Add ?locale=fr to the URL, and you see the changes.  Try adding ?locale=de, and see how it changes.

Please note:

* If you use the "Login" "Signup" links, the locale is correctly keeped.

* If you use the "Home" link, then the locale is missing.

* If you try to change the user using the development fast switcher, it will fail.  

This is because it forces urls like
<http://localhost:3000/dev/set_current_user?locale=en?login=>
instead of 
<http://localhost:3000/dev/set_current_user?locale=en&login=>
Try to use it, and change the ? to & to see it works.

#Step 12:

Let's fix these problems:

Copy the apps/views/taglibs/auto/rapid/pages.dryml definition of main-nav to the apps/views/taglibs/application.dryml.

In apps/views/taglibs/application.dryml file, add the '?locale=#{I18n.locale}' text to the href of the Home item:

    >edit apps/views/taglibs/application.dryml


    <def tag="main-nav">
      <navigation class="main-nav" merge-attrs param="default">
        -<nav-item href="#{base_url}/">Home</nav-item>-
       +<nav-item href="#{base_url}/?locale=#{I18n.locale}">Home</nav-item>+
      </navigation>
    </def>

#Step 13:
Let's add some flag icons in the footer to change the param[:locale], to allow the Guest user to change the locale of the web.

    > edit app/views/taglibs/application.dryml

    <def tag="flags">
        <%= link_to image_tag("/images/es_flag.gif", :border=>0)+" ES", "?locale=es" %>
        <%= link_to image_tag("/images/en_flag.gif", :border=>0)+" EN", "?locale=en" %>
        <%= link_to image_tag("/images/fr_flag.gif", :border=>0)+" FR", "?locale=fr" %>
        <%= link_to image_tag("/images/de_flag.gif", :border=>0)+" DE", "?locale=de" %>
    </def>

    <extend tag="account-nav">
      <old-account-nav merge>
        <prepend-ul:><li><flags/></li></prepend-ul:>
      </old-account-nav>
    </extend>

    > edit app/views/taglibs/application.dryml


    <extend tag="page">
      <old-page merge>
        <footer:>
          +<flags/>+
          <br/>User: <%= current_user %>
          <br/>Locale: <%= I18n.locale %>
          <br/>Params Locale: <%= params[:locale] %>
          <br/>User Locale: <user-lang/>
          <br/>Default Locale: <%= I18n.default_locale %>
        </footer:>
      </old-page>
    </extend>

#Step 15:

The system is almost complete.  A user can specify the locale to use in the web session by clicking on the flag.  If not specified, the locale will be his/her preference in his her profile.  If not, the locale will be set from I18n.default_locale

#TO DO:

* Solve the problem with the development fast user switcher.
* Populate automatically the UserLocale class with the locales found in the config/locales directory, or find a solution that does not require a model.
* When a user has a locale1 preference and uses the flag to select the locale2 preference, some links will ignore the default_url_options functions: the users->show action and the users->account action.
* In the user->show action, solve the way the User Locale is shown (User locale 	`<a class="user_locale-link" href="/user_locales/1-en"><span class="view user-locale-name ">en</span></a>)`



