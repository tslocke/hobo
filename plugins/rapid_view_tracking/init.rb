require 'rapid_view_tracking'

Hobo::Model.send :include, RapidViewTrackingExtensions::ModelExtensions

Hobo::ModelController.send :include, RapidViewTrackingExtensions::ControllerExtensions
