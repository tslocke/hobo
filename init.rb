require 'extensions'
require 'rexml'
require 'active_record/has_many_association'
require 'active_record/has_many_through_association'
require 'active_record/table_definition'
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

  def self.hobo_model_controller(model=nil)
    include Hobo::ModelController
    self.model = model if model
  end

  def self.hobo_controller(model=nil)
    include Hobo::Controller
  end

end

def (ActiveRecord::Base).hobo_model
  include Hobo::Model
end

# Default settings

Hobo.user_model ||= (User rescue (Person rescue nil))

Hobo.developer_features = ["development", "test"].include?(RAILS_ENV) if Hobo.developer_features? == nil
