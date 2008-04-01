class Project < ActiveRecord::Base

  hobo_model

  fields do
    name :string
    timestamps
  end
  
  has_many :stories, :dependent => :destroy
  
  belongs_to :owner, :class_name => "User", :creator => true


  # --- Hobo Permissions --- #

  def creatable_by?(user)
    owner == user
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
