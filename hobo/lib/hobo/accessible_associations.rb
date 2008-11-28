module Hobo
  
  module AccessibleAssociations
    
    extend self
    
    def prepare_has_many_assignment(association, association_name, array_or_hash)
      owner = association.proxy_owner

      array = params_hash_to_array(array_or_hash)
      array.map! do |record_hash_or_string|
        find_or_create_and_update(owner, association, association_name, record_hash_or_string) { association.build }
      end
      array.compact
    end
    
    
    def find_or_create_and_update(owner, association, association_name, record_hash_or_string)
      if record_hash_or_string.is_a?(String)
        # An ID (if it starts '@') or else a name
        record = find_record(association, record_hash_or_string)
      
      elsif record_hash_or_string.is_a?(Hash)
        # A hash of attributes
        hash = record_hash_or_string

        # Remove completely blank hashes
        return nil if hash.values.join.blank?

        id = hash.delete(:id)

        record = if id
                   association.find(id) # TODO: We don't really want to find these one by one
                 else
                   record = yield
                 end
        record.attributes = hash
        owner.include_in_save(association_name, record) unless owner.new_record? && record.new_record?
        
      else
        # It's already a record
        record = record_hash_or_string
      end
      record
    end
    
    
    def params_hash_to_array(array_or_hash)
      if array_or_hash.is_a?(Hash)
        array = array_or_hash.get(*array_or_hash.keys.sort_by(&:to_i))
      else
        array_or_hash
      end
    end
    

    def find_record(association, id_or_name)
      klass = association.member_class
      if id_or_name =~ /^@(.*)/
        id = $1
        if id =~ /:/
          Hobo::Model.find_by_typed_id(id)
        else
          klass.find(id)
        end
      else
        klass.named(id_or_name, :conditions => association.conditions)
      end
    end
  
  end
  
  classy_module(AccessibleAssociations) do
    
    include IncludeInSave
    
    # --- has_many mass assignment support --- #
    
    def self.has_many_with_accessible(name, options={}, &block)
      accessible = options.delete(:accessible)
      has_many_without_accessible(name, options, &block)
      
      if accessible
        class_eval %{
          def #{name}_with_accessible=(array_or_hash)
            items = Hobo::AccessibleAssociations.prepare_has_many_assignment(#{name}, :#{name}, array_or_hash)
            self.#{name}_without_accessible = items
            # ensure the loaded array contains any changed records
            self.#{name}.proxy_target[0..-1] = items
          end
        }, __FILE__, __LINE__ - 7
        alias_method_chain :"#{name}=", :accessible
      end
    end
    metaclass.alias_method_chain :has_many, :accessible
    
    
    
    # --- belongs_to assignment support --- #
    
    def self.belongs_to_with_accessible(name, options={}, &block)
      accessible = options.delete(:accessible)
      belongs_to_without_accessible(name, options, &block)
      
      if accessible
        class_eval %{
          def #{name}_with_accessible=(record_hash_or_string)
            record = Hobo::AccessibleAssociations.find_or_create_and_update(self, #{name}, :#{name}, record_hash_or_string) { self.class.reflections[:#{name}].klass.new }
            self.#{name}_without_accessible = record
          end
        }, __FILE__, __LINE__ - 5
        alias_method_chain :"#{name}=", :accessible
      end
    end
    metaclass.alias_method_chain :belongs_to, :accessible
    
  end    
  
end
