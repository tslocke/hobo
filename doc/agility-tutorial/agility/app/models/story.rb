class Story < ActiveRecord::Base

  hobo_model

  fields do
    title :string
    body :markdown
    timestamps
  end

  belongs_to :status, :class_name => "StoryStatus", :foreign_key => "status_id"
  belongs_to :project
  has_many :tasks, :dependent => :destroy
    
  
  # --- Hobo Permissions --- #

  def creatable_by?(user)
    true
  end

  def updatable_by?(user, new)
    !user.guest? && same_fields?(new, :project)
  end

  def deletable_by?(user)
    !user.guest?
  end

  def viewable_by?(user, field)
    true
  end

end
