class ActiveRecord::Reflection::AssociationReflection

  alias_method :association_name, :name

  def klass_with_create_polymorphic_class
    if options[:polymorphic]
      begin
        klass_without_create_polymorphic_class
      rescue NameError => e
        Object.class_eval "class #{e.missing_name} < ActiveRecord::Base; set_table_name '#{active_record.name.tableize}'; end"
        e.missing_name.constantize
      end
    else
      klass_without_create_polymorphic_class
    end
  end
  alias_method_chain :klass, :create_polymorphic_class

end
