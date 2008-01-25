bundle_model :ForumTopic do

  fields do
    title          :string
    sticky         :boolean, :default => false
    body           :text
    last_post_at   :datetime
    timestamps
  end

  has_many   :replies, :class_name => _ForumPost_, :foreign_key => 'topic_id', :order => :created_at, :dependent => :destroy
  belongs_to :forum

  belongs_to :user, :creator => true

  belongs_to :last_post_by, :class_name => 'User'

  def_scope :recent, :order => "last_post_at DESC"

  track_viewings :class_name => "ForumTopicViewing"

  validates_presence_of :title, :body

  before_create :set_last_post

  def has_replies?
    @has_replies ||= (posts_count > 1)
  end

  def posts_count
    @posts_count ||= (1 + replies.count)
  end

  def unread_posts?(user)
    unless user.guest?
      v = viewings.find_by_user_id(user.id)
      user.created_at < self.last_post_at && (v.nil? || v.updated_at < self.last_post_at)
    end
  end

  # --- Hobo Permissions --- #

  # Anyone can post as long as they don't fake the post as from
  # another user. Also if the post is marked as sticky the creator
  # must be an admin.
  def creatable_by?(user)
    user == self.user && sticky?.implies(user.administrator?) && view_counter == 0
  end

  # Admins can change the sticky flag and the title. 
  def updatable_by?(user, new)
    (user.administrator? && only_changed_fields?(new, :sticky, :title, :body)) || 
    (user == self.user && same_fields?(new, :user, :forum, :sticky, :view_counter))
  end

  # Admins can delete the topic.
  def deletable_by?(user)
    user.administrator?
   end

  # Anyone can view, even guests.
  def viewable_by?(user, field)
    true
  end

  def last_post_at_editable_by?(user)
    false
  end
  
  def last_post_by_editable_by?(user)
    false
  end

  protected
  
  def set_last_post
    self.last_post_at = Time.now
    self.last_post_by = user
  end

end
