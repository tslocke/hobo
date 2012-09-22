class TaskAssignment < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
  end

  belongs_to :user, :inverse_of => :task_assignments
  belongs_to :task, :inverse_of => :task_assignments

  # --- Permissions --- #

  def create_permitted?
    task.creatable_by?(acting_user)
  end

  def update_permitted?
    task.updatable_by?(acting_user)
  end

  def destroy_permitted?
    task.destroyable_by?(acting_user)
  end

  def view_permitted?(field)
    task.viewable_by?(acting_user)
  end

end
