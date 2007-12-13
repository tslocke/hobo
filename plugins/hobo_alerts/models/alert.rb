plugin_model :Alert do 
  
  fields do
    name :string
    timestamps
  end

  belongs_to :user,    (_polymorphic_user_    ? { :polymorphic => true } : { :class_name => _AlertUser_ })
  belongs_to :subject, (_polymorphic_subject_ ? { :polymorphic => true } : { :class_name => _AlertSubject_ })
  
  def self.alert(users, subject, name)
    users.each { |u| create(:user => u, :subject => subject, :name => name.to_s) }
  end
  
  def creatable_by?(user);         false; end
  def updatable_by?(user, new);    false; end
  def deletable_by?(deleter);      deleter == user; end
  def viewable_by?(viewer, field); viewer == user;  end

end
