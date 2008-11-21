class <%= class_name %> < ActiveRecord::Base

  hobo_user_model # Don't put anything above this

  fields do
    username :string, :login => true, :name => true
    email_address :email_address
    administrator :boolean, :default => false
    timestamps
  end

  # This gives admin rights to the first sign-up.
  # Just remove it if you don't want that
  before_create { |user| user.administrator = true if count == 0 }
  
  
  # --- Signup lifecycle --- #

  lifecycle do

    state :active, :default => true

    create :signup, :available_to => "Hobo::Guest",
           :params => [:username, :email_address, :password, :password_confirmation],
           :become => :active

    transition :request_password_reset, { :active => :active }, :new_key => true do
      <%= class_name %>Mailer.deliver_forgot_password(self, lifecycle.key)
    end

    transition :reset_password, { :active => :active }, :available_to => :key_holder,
               :update => [ :password, :password_confirmation ]
               

  end
  

  # --- Permissions --- #

  def creatable_by?(creator)
    creator.administrator? || !administrator
  end

  def updatable_by?(updater, updated)
    updater.administrator? ||
      (updater == self && only_changed_fields?(updated, :password, :password_confirmation, :email_address))
  end

  def deletable_by?(deleter)
    deleter.administrator?
  end

  def viewable_by?(viewer, field)
    true
  end

end
