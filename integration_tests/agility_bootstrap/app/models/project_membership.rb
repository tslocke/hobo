class ProjectMembership < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    contributor :boolean, :default => false
    timestamps
  end

  belongs_to :project, :inverse_of => :memberships
  belongs_to :user, :inverse_of => :project_memberships

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator? || project.owner_is?(acting_user)
  end

  def update_permitted?
    acting_user.administrator? || project.owner_is?(acting_user)
  end

  def destroy_permitted?
    acting_user.administrator? || project.owner_is?(acting_user)
  end

  def view_permitted?(field)
    true
  end

end
