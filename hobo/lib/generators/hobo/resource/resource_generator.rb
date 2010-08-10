module Hobo
  class ResourceGenerator < Rails::Generators::NamedBase

    argument :attributes,
             :type => :array,
             :default => [],
             :banner => "field:type field:type"

    class_option :timestamps,
                 :type => :boolean

    def generate_hobo_controller
      invoke 'hobo:controller', [name.pluralize], options
    end

    def generate_hobo_model
      invoke 'hobo:model', [name.singularize], attributes, options
    end

  end
end
