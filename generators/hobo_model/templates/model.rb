class <%= class_name %> < ActiveRecord::Base

  hobo_model


  # --- Hobo Permissions --- #

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

end
