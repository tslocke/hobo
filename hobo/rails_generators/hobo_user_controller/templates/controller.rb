class <%= class_name %>Controller < ApplicationController

  hobo_user_controller

  auto_actions :all, :except => [ :index, :new, :create ]
<% if invite_only? -%>

  def create
    hobo_create do
      if valid?
        self.current_user = this
        this.password = this.password_confirmation = nil # don't trigger password change validations
        this.state = 'active'
        this.save
        flash[:notice] = ht("hobo.messages.you_are_site_admin", :default=>"You are now the site administrator")
        redirect_to home_page
      end
    end
  end

  def do_accept_invitation
    do_transition_action :accept_invitation do
      self.current_user = this
      flash[:notice] = ht("hobo.messages.you_signed_up", :default=>"You have signed up")
    end
  end
<% end -%>

end
