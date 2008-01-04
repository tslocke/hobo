class ForumTopic < ActiveRecord::Base

  # See app/models/forum.rb for comments on hobo_model and "fields do"

  hobo_model

  fields do
    title          :string
    sticky         :boolean, :default => false
    body           :text
    last_post_at   :datetime
    timestamps
  end

  # See app/models/forum.rb for some comments on the :dependent declaration
  has_many   :replies, :class_name => 'ForumPost', :foreign_key => 'topic_id', :order => :created_at, :dependent => :destroy
  belongs_to :forum

  def_scope :recent, :order => "last_post_at DESC"
  
  # See app/models/forum_post.rb for an explanation of :creator => true
  belongs_to :user, :creator => true

  belongs_to :last_post_by, :class_name => 'User'

  before_create :set_last_post

  def has_replies?
    @has_replies ||= (posts_count > 1)
  end

  def posts_count
    @posts_count ||= (1 + replies.count)
  end

  # --- Hobo Permissions --- #

  # Anyone can post as long as they don't fake the post as from
  # another user. Also if the post is marked as sticky the creator
  # must be an admin.
  def creatable_by?(user)
    user == self.user && sticky?.implies(user.administrator?)
  end

  # Admins can change the sticky flag and the title. 
  def updatable_by?(user, new)
    user.administrator? && only_changed_fields?(new, :sticky, :title)
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
