bundle_model :BlogPost do

  fields do |f|
    f.title        :string
    f.body         _format_
    f.published_at :datetime
    f.timestamps
  end
  
  set_default_order 'created_at DESC'
  
  def_scope :published, :conditions => [ "#{table_name}.published_at <= ?", Time.now ]
  
  # Temporary - auto-publish until we've implemented the ability to manage post publishing
  after_create {|post| post.update_attribute :published_at, post.created_at }
  
  feature :comments do
    has_many :comments, :order => 'created_at ASC', :class_name => _BlogPostComment_, :dependent => :destroy
  end
  
  feature :categories do 
    has_many :categorisations, :class_name => _BlogPostCategorisation_
    has_many :categories, :through => :categorisations, :class_name => _BlogPostCategory_, :source => :blog_post_category
  end

  feature :author do
    belongs_to :author, :class_name => _Author_, :creator => true
  end
  
  def self.all_posts_by_month
    find(:all, :order => 'created_at DESC').group_by {|i|i.created_at.beginning_of_month}.sort.reverse
  end
  
  
  # --- Permissions --- #
  
  def allow_access?(user)
    user.administrator? || (features_author? && author == user)
  end

  def creatable_by?(user)
    allow_access?(user) && published_at.nil?
  end
  
  def updatable_by?(user, new)
    allow_access?(user) && same_fields?(new, :author, :published_at)
  end
  
  def deletable_by?(user)
    allow_access?(user)
  end
  
  def viewable_by?(user, field); true;  end
   
end
