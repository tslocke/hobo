bundle_model :ForumMembership do
  fields do
    moderator :boolean
    timestamps
  end
  
  belongs_to :forum, :class_name => _Forum_
  belongs_to :user,  :class_name => _User_

  # --- Hobo Permissions --- #
  
  # Administrators can make any changes, but anyone can view any of
  # the fields.

  def creatable_by?(user)
    user.administrator?
  end

  def updatable_by?(user, new)
    user.administrator?
  end
  
  def deletable_by?(user)
    false
  end

  def viewable_by?(user, field)
    true
  end
end