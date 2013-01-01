# Why can't I call acting_user or current_user in x method in my model?

Originally written by kevinpfromnm on 2010-08-04.

class User < ActiveRecord::Base

  hobo_user_model # Don't put anything above this
  if acting_user.administrator? then  
  fields do
      name          :string, :required, :unique
      email_address :email_address, :login => true
      administrator :boolean, :default => false
      timestamps
    end
  end

  belongs_to :group

  # --- Signup lifecycle --- #

  lifecycle do

    state :active, :default => true

    create :signup, :available_to => "Guest",
           :params => [:name, :email_address, :password,
:password_confirmation],
           :become => :active

    transition :request_password_reset, { :active => :active }, :new_key => true
do
      UserMailer.deliver_forgot_password(self, lifecycle.key)
    end

    transition :reset_password, { :active => :active }, :available_to =>
:key_holder,
               :params => [ :password, :password_confirmation ]

  end

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator? ||
      (acting_user == self && only_changed?(:email_address, :crypted_password,
                                            :current_password, :password,
:password_confirmation))
    # Note: crypted_password has attr_protected so although it is permitted to
change, it cannot be changed
    # directly from a form submission.
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    acting_user.administrator?
  end

end