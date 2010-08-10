module Hobo
  class ControllerGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)
    include Generators::Hobo::Controller
  end
end
