class ActiveRecord::Reflection::AssociationReflection

  alias_method :association_name, :name

  def safe_class
    klass
  rescue NameError
    nil
  end
  
end
