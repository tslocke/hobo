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
  

  # --- Hobo Permissions --- #

  def creatable_by?(creator)
    creator.administrator? || !administrator
  end

  def updatable_by?(updater, new)
    updater.administrator? || (updater == self && only_changed_fields?(new, :password, :password_confirmation))
  end

  def deletable_by?(deleter)
    deleter.administrator?
  end

  def viewable_by?(viewer, field)
    true
  end

end
