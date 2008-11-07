class <%= class_name %>Controller < <%= subsite ? "#{subsite}::#{subsite}SiteController" : "ApplicationController" %>

  hobo_model_controller

  auto_actions :all

end
