class <%= class_name %> < ActiveRecord::Base

  hobo_user_model

  fields do
    username :string, :login => true
    timestamps
  end
  
  alias_attribute :to_s, :username

  # --- Hobo Permissions --- #

  # It is possible to override the permission system entirely by
  # returning true from super_user?
  # def super_user?; true; end


  # This method has no special meaning to the permission system. It is
  # used by some standard Hobo plugins such as hobo_blog. Redefine to
  # taste.
  def administrator?
    login == "admin"
  end

  def creatable_by?(creator)
    true
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

end
