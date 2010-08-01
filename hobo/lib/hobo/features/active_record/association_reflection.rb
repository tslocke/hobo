class ActiveRecord::Reflection::AssociationReflection

  alias_method :association_name, :name

  def klass_with_create_polymorphic_class
    if options[:polymorphic]
      begin
        klass_without_create_polymorphic_class
      rescue NameError => e
        name = "#{active_record.name}::#{class_name}"
        Object.class_eval "class #{name}; end"
        active_record.const_get class_name
      end
    else
      klass_without_create_polymorphic_class
    end
  end
  alias_method_chain :klass, :create_polymorphic_class

end
