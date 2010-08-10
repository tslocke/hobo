module Generators
  module HoboSupport
    Model = classy_module do

      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"

      def self.banner
      "rails generate hobo:model #{self.arguments.map(&:usage).join(' ')} [options]"
      end

      class_option :timestamps, :type => :boolean

      def generate_model
        invoke "active_record:model", [name], :migration => false
      end

      def inject_hobo_code_into_model_file
        source  = File.expand_path(find_in_source_paths('model_injection.rb.erb'))
        context = instance_eval('binding')
        inject_into_class model_path, class_name do
          ERB.new(::File.binread(source), nil, '-').result(context)
        end
      end

      protected

      def model_path
        @model_path ||= File.join("app", "models", "#{file_path}.rb")
      end

      def max_attribute_length
        attributes.*.name.*.length.max
      end

      def field_attributes
        attributes.reject { |a| a.name == "bt" || a.name == "hm" }
      end

      def hms
        attributes.select { |a| a.name == "hm" }.*.type
      end

      def bts
        attributes.select { |a| a.name == "bt" }.*.type
      end

    end
  end
end
