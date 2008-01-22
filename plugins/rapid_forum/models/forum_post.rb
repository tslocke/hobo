bundle_model :ForumPost do

  # See app/models/forum.rb for comments on hobo_model and "fields do"
  fields do
    body       :text
    timestamps
  end

  belongs_to :topic, :class_name => _ForumTopic_, :foreign_key => 'topic_id'
  
  # :creator => true tells Hobo that this association represents the
  # user that creates the post. The controller and view layers will
  # set this association automatically to the logged in user (if
  # any). Adding this declaration where appropriate *greatly* improves
  # what can be achieved by the permission system, as the association
  # will be set up before the permission methods are called.
  belongs_to :user, :creator => true

  validates_presence_of :body

  after_create :update_topic_last_post

  # --- Hobo Permissions --- #

  # Anyone can create a post as long as they haven't tried to fake the
  # post as from a different user. Note this test will never be true
  # for guests, so this rules out guests posting too.
  def creatable_by?(user)
    user == self.user
  end

  # Only an admin can make changes and they can only change the body
  # (i.e. they can't change the user that the post is associated with)
  def updatable_by?(user, new)
    user.administrator? && only_changed_fields?(new, :body)
  end
  
  # Only admins can delete the post
  def deletable_by?(user)
    user.administrator?
  end
  
  # Everyone can view the post -- even guests.
  def viewable_by?(user, field)
    true
  end

  protected
  
  def update_topic_last_post
    topic.last_post_at = Time.now
    topic.last_post_by = self.user
    topic.save!
  end

end
