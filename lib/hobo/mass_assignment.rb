module Hobo
  
  MassAssignment = classy_module do
    
    include IncludeInSave
    
    
    # --- has_many mass assignment support --- #
    
    def self.has_many_with_mass_assignment(name, options={}, &block)
      accessible = options.delete(:accessible)
      has_many_without_mass_assignment(name, options, &block)
      
      if accessible
        class_eval %{
          def #{name}_with_mass_assignment=(array_or_hash)
            self.#{name}_without_mass_assignment = prepare_has_many_assignment(:#{name}, array_or_hash)
          end}, __FILE__, __LINE__ - 3
        alias_method_chain :"#{name}=", :mass_assignment
      end
    end
    metaclass.alias_method_chain :has_many, :mass_assignment
    
    
    def prepare_has_many_assignment(association_name, array_or_hash)
      association = send(association_name)

      array = params_hash_to_array(array_or_hash)
      array.map do |record_or_hash|
        if record_or_hash.is_a?(Hash)
          hash = record_or_hash

          id = hash.delete(:id)
          record = if id
                     association.find(id) # TODO: We don't really want to find these one by one
                   else
                     # Remove completely blank hashes
                     next if hash.values.join.blank?

                     record = association.build
                   end
          record.attributes = hash
          include_in_save(association_name, record)
        else
          record = record_or_hash
        end
        record

      end.compact

    end      
    
    def params_hash_to_array(array_or_hash)
      if array_or_hash.is_a?(Hash)
        array = array_or_hash.get(*array_or_hash.keys.sort_by(&:to_i))
      else
        array_or_hash
      end
    end
  end    
end
