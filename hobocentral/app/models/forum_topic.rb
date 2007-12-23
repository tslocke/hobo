class ForumTopic < ActiveRecord::Base

  # See app/models/forum.rb for comments on hobo_model and "fields do"

  hobo_model

  fields do
    title      :string
    sticky     :boolean
    timestamps
  end

  # See app/models/forum.rb for some comments on the :dependent declaration
  has_many   :posts, :class_name => 'ForumPost', :foreign_key => 'topic_id', :order => :created_at, :dependent => :destroy
  belongs_to :forum
  
  # See app/models/forum_post.rb for an explanation of :creator => true
  belongs_to :user, :creator => true

  # A virtual field -- this is all regular Active Record
  attr_accessor :body

  after_save :save_body
  def save_body
    post = posts.find(:first) || posts.new
    
    post.user = self.user
    post.body = self.body
    post.save
  end

  def last_post
    posts.find(:first, :order => 'created_at DESC')
  end

  def replies
    posts[1..-1] || []
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
    user.administrator? && only_changed_fields(new, :sticky, :title)
  end

  # Admins can delete the topic.
  def deletable_by?(user)
    user.administrator?
   end

  # Anyone can view, even guests.
  def viewable_by?(user, field)
    true
  end

end
