bundle_model :Tag do 
  
  fields do |f|
    f.name :string
  end
  
  has_many :taggings, :class_name => _Tagging_
  has_many :targets, :through => :taggings, :class_name => _TagTarget_

  def creatable_by?(user);       user.administrator? end
  def updatable_by?(user, new);  user.administrator? end
  def deletable_by?(user);       user.administrator? end
  def viewable_by?(user, field); true; end
end
