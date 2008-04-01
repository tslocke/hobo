class TaskAssignment < ActiveRecord::Base

  hobo_model

  fields do
    timestamps
  end
  
  belongs_to :task
  belongs_to :user


  # --- Hobo Permissions --- #

  def creatable_by?(user)
    user.administrator?
  end

  def updatable_by?(user, new)
    user.administrator?
  end

  def deletable_by?(user)
    user.administrator?
  end

  def viewable_by?(user, field)
    true
  end

end
