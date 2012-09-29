class UsersController < ApplicationController

  hobo_user_controller

  auto_actions :all, :except => [ :index, :new, :create ]

  autocomplete

  def create
    hobo_create do
      if valid?
        self.current_user = this
        flash[:notice] = t("hobo.messages.you_are_site_admin", :default=>"You are now the site administrator")
        redirect_to home_page
      end
    end
  end

  def do_signup
    hobo_do_signup do
      if this.errors.blank?
        flash[:notice] << "You must activate your account before you can log in.  Please check your email."
        
        # FIXME: remove these two lines after you get email working reliably
        # and before your application leaves its sandbox...
        secret_path = activate_user_path :id=>this.id, :key => this.lifecycle.key
        flash[:notice] = "Thanks for signing up!  The 'secret' link that was just emailed was: <a id='activation-link' href='#{secret_path}'>#{secret_path}</a>.".html_safe
      end
    end
  end

end
