# gem dependencies
require 'hobosupport'

# Force load:
HoboFields

# Monkey patches, ooh ooh
require 'rexml'
require 'active_record/has_many_association'
require 'active_record/has_many_through_association'
require 'active_record/association_proxy'
require 'active_record/association_reflection'
require 'action_view_extensions/base'

require 'hobo'
require 'hobo/dryml'

require 'hobo/model'

require 'hobo/dryml/template'
require 'hobo/dryml/taglib'
require 'hobo/dryml/template_environment'
require 'hobo/dryml/template_handler'

require 'extensions/test_case' if RAILS_ENV == "test"


ActionView::Base.register_template_handler("dryml", Hobo::Dryml::TemplateHandler)

class ActionController::Base

  def self.hobo_user_controller(model=nil)
    @model = model
    include Hobo::ModelController
    include Hobo::UserController
  end

  def self.hobo_model_controller(model=nil)
    @model = model
    include Hobo::ModelController
  end

  def self.hobo_controller
    include Hobo::Controller
  end

end

class ActiveRecord::Base
  def self.hobo_model
    include Hobo::Model
  end
  def self.hobo_user_model
    include Hobo::Model
    include Hobo::User
  end
end

# Default settings

Hobo.developer_features = RAILS_ENV.in?(["development", "test"]) if Hobo.developer_features?.nil?


module ::Hobo
  # Empty class to represent the boolean type.
  class Boolean; end
end


if defined? HoboFields
  HoboFields.never_wrap(Hobo::Undefined)
end
