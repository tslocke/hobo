module Hobo
  
  module AccessibleAssociations
    
    extend self
    
    def prepare_has_many_assignment(association, association_name, array_or_hash)
      owner = association.proxy_owner

      array = params_hash_to_array(array_or_hash)
      array.map! do |record_hash_or_string|
        finder = association.member_class.scoped :conditions => association.conditions
        find_or_create_and_update(owner, association_name, finder, record_hash_or_string) do |id|
          # The block is required to either locate find an existing record in the collection, or build a new one
          if id
            # TODO: We don't really want to find these one by one
            association.find(id)
          else
            association.build
          end
        end
      end
      array.compact
    end
    
    
    def find_or_create_and_update(owner, association_name, finder, record_hash_or_string)
      if record_hash_or_string.is_a?(String)
        # An ID or a name - the passed block will find the record
        record = find_by_name_or_id(finder, record_hash_or_string)
      
      elsif record_hash_or_string.is_a?(Hash)
        # A hash of attributes
        hash = record_hash_or_string

        # Remove completely blank hashes
        return nil if hash.values.all?(&:blank?)

        id = hash.delete(:id)

        record = yield id
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
    

    def find_by_name_or_id(finder, id_or_name)
      if id_or_name =~ /^@(.*)/
        id = $1
        finder.find(id)
      else
        finder.named(id_or_name)
      end
    end
  
  end
  
  classy_module(AccessibleAssociations) do
    
    include IncludeInSave
    
    # --- has_many mass assignment support --- #
    
    def self.has_many_with_accessible(name, options={}, &block)
      has_many_without_accessible(name, options, &block)
      
      if options[:accessible]
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
      belongs_to_without_accessible(name, options, &block)
      
      if options[:accessible]
        class_eval %{
          def #{name}_with_accessible=(record_hash_or_string)
            refl = self.class.reflections[:#{name}]
            conditions = ActiveRecord::Associations::BelongsToAssociation.new(self, refl).conditions
            finder = refl.klass.scoped(:conditions => conditions)
            record = Hobo::AccessibleAssociations.find_or_create_and_update(self, :#{name}, finder, record_hash_or_string) do |id|
              if id
                raise ArgumentError, "attempted to update the wrong record in belongs_to association #{self}##{name}" unless 
                  #{name} && id == self.#{name}.id
                #{name}
              else
                refl.klass.new
              end
            end
            self.#{name}_without_accessible = record
          end
        }, __FILE__, __LINE__ - 5
        alias_method_chain :"#{name}=", :accessible
      end
    end
    metaclass.alias_method_chain :belongs_to, :accessible
    
    
    # Add :accessible to the valid keys so AR doesn't complain

    def self.valid_keys_for_has_many_association_with_accessible
      valid_keys_for_has_many_association_without_accessible + [:accessible]
    end
    metaclass.alias_method_chain :valid_keys_for_has_many_association, :accessible

    def self.valid_keys_for_belongs_to_association_with_accessible
      valid_keys_for_belongs_to_association_without_accessible + [:accessible]
    end
    metaclass.alias_method_chain :valid_keys_for_belongs_to_association, :accessible
    
    
  end    
  
end
