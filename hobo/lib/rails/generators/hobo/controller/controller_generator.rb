module Hobo
  class ControllerGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)
    include Hobo::Generators::ControllerModule
  end
end
