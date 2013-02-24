Rails.application.routes.draw do

  get 'dryml/:action', :controller => 'dryml_support', :as => 'dryml_support'
  get 'dev/:action', :controller => 'dev', :as => 'dev_support' if Rails.application.config.hobo.developer_features

end
