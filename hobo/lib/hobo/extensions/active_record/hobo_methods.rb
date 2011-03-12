ActiveRecord::Base.class_eval do
  def self.hobo_model
    include Hobo::Model
    fields(false) # force hobo_fields to load
  end
  def self.hobo_user_model
    include Hobo::Model
    include Hobo::Model::UserBase
  end
  alias_method :has_hobo_method?, :respond_to_without_attributes?
end
