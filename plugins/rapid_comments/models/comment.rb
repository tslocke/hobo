bundle_model :Comment do
  
  fields do |f|
    f.author  :string, :creator => true unless _author_model_
    f.body    _format_
    f.website :string if _website_
    f.timestamps
  end

  belongs_to _comment_target_

  validates_presence_of :body
  
  feature :author_model do
    belongs_to :author, :class_name => _Author_, :creator => true
  end
  
  def creatable_by?(user);       true; end
  def updatable_by?(user, new);  user.administrator?; end
  def deletable_by?(user);       user.administrator?; end
  def viewable_by?(user, field); true; end
  
end
