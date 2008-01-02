class <%= class_name %> < ActiveRecord::Base

  hobo_user_model

  fields do
    username :string, :login => true, :name => true
    administrator :boolean, :default => false
    timestamps
  end

  set_admin_on_first_user
  
  # --- Hobo Permissions --- #

  # It is possible to override the permission system entirely by
  # returning true from super_user?
  # def super_user?; true; end

  def creatable_by?(creator)
    true
  end

  def updatable_by?(updater, new)
    updater.administrator?
  end

  def deletable_by?(deleter)
    deleter.administrator?
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

end
