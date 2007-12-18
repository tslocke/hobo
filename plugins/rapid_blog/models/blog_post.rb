bundle_model :BlogPost do
  
  fields do |f|
    f.title :string
    f.body  _format_
    f.timestamps
  end
  
  set_default_order 'created_at DESC'
  
  feature :comments do
    has_many :comments, :order => 'created_at ASC', :class_name => _BlogPostComment_
  end
  
  feature :categories do 
    has_many :categorisations, :class_name => _BlogPostCategorisation_
    has_many :categories, :through => :categorisations, :class_name => _BlogPostCategory_, :source => :blog_post_category
  end
  
  def_scope :recent do |limit|
    { :limit => limit, :order => 'created_at DESC' }
  end
   
  def creatable_by?(user);       user.administrator?; end
  def updatable_by?(user, new);  user.administrator?; end
  def deletable_by?(user);       user.administrator?; end
  def viewable_by?(user, field); true;  end
   
end
