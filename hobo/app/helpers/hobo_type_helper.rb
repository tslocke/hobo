module HoboTypeHelper
  extend HoboHelperBase
  protected
    def type_id(type=nil)
      type ||= (this.is_a?(Class) && this) || this_type || this.class
      HoboFields.to_name(type) || type.name.to_s.underscore.gsub("/", "__")
    end


    def type_and_field(*args)
      type, field = args.empty? ? [this_parent.class, this_field] : args
      "#{type.typed_id}_#{field}" if type.respond_to?(:typed_id)
    end


    def model_id_class(object=this, attribute=nil)
      object.respond_to?(:typed_id) ? "model::#{typed_id(object, attribute).to_s.dasherize}" : ""
    end


    def css_data(name, *args)
      "#{name.to_s.dasherize}::#{args * '::'}"
    end
end
