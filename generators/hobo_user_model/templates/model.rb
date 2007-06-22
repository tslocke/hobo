class <%= class_name %> < ActiveRecord::Base

  hobo_model

  include Hobo::AuthenticatedUser
  
  set_login_attr :username
  
  alias_attribute :display_name, :username

  # --- Hobo Permissions --- #

  def super_user?
    # Return true to make this user exempt from permission restrictions
    # e.g.
    # login == 'admin'
  end

  def creatable_by?(creator)
    false
  end

  def updatable_by?(updater, new)
    false
  end

  def deletable_by?(deleter)
    false
  end

  def viewable_by?(viewer, field)
    true
  end


  # --- Fallback permissions --- #

  # (Hobo checks these for models that do not define the *_by? methods)

  def can_create?(obj)
    false
  end

  def can_update?(obj, new)
    false
  end

  def can_delete?(obj)
    false
  end

  def can_view?(obj, field)
    true
  end

  def guest?
    false
  end

end
