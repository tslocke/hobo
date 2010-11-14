Rails.application.routes.draw do

  match 'dryml/:action', :controller => 'dryml_support', :as => 'dryml_support'
  match 'dev/:action', :controller => 'dev', :as => 'dev_support' if Rails.application.config.hobo.developer_features

end
