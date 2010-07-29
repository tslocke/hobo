module Hobo
  class ModelGenerator < Rails::Generators::NamedBase

    def self.banner
      "rails generate hobo:model #{self.arguments.map(&:usage).join(' ')} [options]"
    end

    # work around: for some reason the USAGE file is not shown withouth this line
    desc File.read(File.expand_path('../USAGE', __FILE__))

    argument :attributes,
             :type => :array,
             :default => [],
             :banner => "field:type field:type"

    class_option :timestamps, :type => :boolean

    hook_for :orm

    def inject_fields_block_into_model_file
      data = "\n  fields do\n"
      attributes.reject {|attr| attr.reference? }.each do |attribute|
        data << "    #{attribute.name} :#{attribute.type}\n"
      end
      data << "timestamps\n" if options[:timestamps]
      data << "  end\n"

      model_path = File.join("app/models", class_path, "#{file_name}.rb")
      inject_into_file model_path, data, :after => /class[^\n]+/
    end

  end
end
