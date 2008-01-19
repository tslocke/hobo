require 'rapid_view_tracking'

ActiveRecord::Base.send :include, RapidViewTracking::ModelExtensions

Hobo::ModelController.send :include, RapidViewTracking::ModelControllerExtensions
