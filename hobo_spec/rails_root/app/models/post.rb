class Post < ActiveRecord::Base
  
  hobo_model
  
  fields do
    title :string
    body :text
    timestamps
  end
  
  belongs_to :user, :creator => true
  
  has_many :comments
  has_many :categorisations
  has_many :categories, :through => :categorisations
  
  def viewable_by?(user, field)
    true
  end
  
  def creatable_by?(creator)
    creator == user && body !~ /CANNOT CREATE/
  end
  
  def updatable_by?(updater, new)
    updater == user && same_fields?(new, :user)
  end
  
  def deletable_by?(deleter)
    deleter == user
  end
  
  
end
