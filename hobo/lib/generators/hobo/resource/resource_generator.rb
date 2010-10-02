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
      # is there any better way to pass attributes?
      attr = attributes.map{|a| "#{a.name}:#{a.type}"}
      invoke 'hobo:model', [name.singularize, attr], options
    end

  end
end
