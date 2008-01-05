class User < ActiveRecord::Base

  hobo_user_model

  fields do
    username :string, :login => true, :name => true
    timestamps
  end

  has_many :forum_posts
  has_many :topics, :through => :forum_posts, :uniq => true

  # --- Hobo Permissions --- #

  def administrator?
    username == 'admin'
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
