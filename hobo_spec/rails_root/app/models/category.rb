class Category < ActiveRecord::Base
  
  hobo_model
  
  fields do
    name :string, :unique
    timestamps
  end
  
  has_many :categorisations
  has_many :posts, :through => :categorisations
  
  def viewable_by?(user, field)
    true
  end
  
  def creatable_by?(creator)
    creator.is_a?(Administrator)
  end
  
  def updatable_by?(updater, new)
    updater.is_a?(Administrator)
  end
  
  def deletable_by?(deleter)
    deleter.is_a?(Administrator)
  end

  
end
