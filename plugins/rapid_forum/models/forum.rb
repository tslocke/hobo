bundle_model :Forum do

  # Declare some fields -- these are picked up by the migration
  # generator. Any changes you make to these can be automatically
  # applied to the database by the migration generator. You can also
  # extend the set of types available (e.g. see
  # hobo/lib/hobo/email_address.rb). We call these "rich types" they
  # can have custom validations, and can be picked up by the view
  # later for custom rendering.
  fields do
    title           :string, :name => true
    description     :text
    
    # Add create_at and updated_at fields in one go
    timestamps
  end

  # Hobo Rapid will spot the :dependent declaration here and use the
  # information to improve the default pages.
  has_many :topics, :class_name => _ForumTopic_, :order => 'sticky desc, last_post_at desc', :dependent => :destroy

  def topics_count
    @topics_count ||= topics.count
  end

  def posts_count
    @posts_count ||= topics.inject(0) {|sum,topic|sum + topic.posts_count}
  end

  def last_update
    topics.recent.find(:first)
  end

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
    user.administrator?
  end

  def viewable_by?(user, field)
    true
  end

end
