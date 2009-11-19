module Hobo
  
  module Permissions
    
    module Associations
    
      def self.enable
      
        # Re-open AR classes...
      
        ActiveRecord::Associations::HasManyAssociation.class_eval do

          # Helper - the user acting on the owner (if there is one)
          def acting_user
            @owner.acting_user if @owner.is_a?(Hobo::Model)
          end


          def delete_records(records)
            case @reflection.options[:dependent]
              when :destroy
                records.each { |r| r.is_a?(Hobo::Model) ? r.user_destroy(acting_user) : r.destroy }
              when :delete_all
                # No destroy permission check if the :delete_all option has been chosen
                @reflection.klass.delete(records.map(&:id))
              else
                nullify_keys(records)
            end
          end
        

          # Set the fkey used by this has_many to null on the passed records, checking for permission first if both the owner
          # and record in question are Hobo models
          def nullify_keys(records)
            if (user = acting_user)
              records.each { |r| r.user_update_attributes!(user, @reflection.primary_key_name => nil) if r.is_a?(Hobo::Model) }
            end

            # Normal ActiveRecord implementatin
            ids = quoted_record_ids(records)
            @reflection.klass.update_all(
              "#{@reflection.primary_key_name} = NULL", 
              "#{@reflection.primary_key_name} = #{@owner.quoted_id} AND #{@reflection.klass.primary_key} IN (#{ids})"
            )
          end


          def insert_record(record, force = false, validate = true)
            set_belongs_to_association_for(record)
            if (user = acting_user) && record.is_a?(Hobo::Model)
              if force
                record.user_save!(user)
              else
                record.user_save(user, validate)
              end
            else
               if force 
                 record.save!
               else
                 record.save(validate)
               end
            end
          end
          
          def viewable_by?(user, field=nil)
            # view check on an example member record is not supported on associations with conditions
            return true if @reflection.options[:conditions]
            new_candidate.viewable_by?(user, field)
          end
        
        end
      
        ActiveRecord::Associations::HasManyThroughAssociation.class_eval do
        
          def acting_user
            @owner.acting_user if @owner.is_a?(Hobo::Model)
          end

        
          def create!(attrs = nil)
            klass = @reflection.klass
            user = acting_user if klass < Hobo::Model
            klass.transaction do
              object = if attrs
                         klass.send(:with_scope, :create => attrs) { user ? klass.user_create!(user) : klass.create! }
                       else
                         user ? klass.user_create!(user) : klass.create!
                       end
              self << object
              object
            end
          end


          def create(attrs = nil)
            klass = @reflection.klass
            user = acting_user if klass < Hobo::Model
            klass.transaction do
              object = if attrs
                         klass.send(:with_scope, :create => attrs) { user ? klass.user_create(user) : klass.create }
                       else
                         user ? klass.user_create(user) : klass.create
                       end
              self << object
              object
            end
          end
        
        
          def insert_record(record, force=true, validate=true)
            user = acting_user if record.is_a?(Hobo::Model)
            if record.new_record?
              if force
                user ? record.user_save!(user) : record.save!
              else
                return false unless (user ? record.user_save(user, validate) : record.save(validate))
              end
            end
            klass = @reflection.through_reflection.klass
            @owner.send(@reflection.through_reflection.name).proxy_target << 
              klass.send(:with_scope, :create => construct_join_attributes(record)) { user ? klass.user_create!(user) : klass.create! }
          end


          # TODO - add dependent option support
          def delete_records_with_hobo_permission_check(records)
            klass  = @reflection.through_reflection.klass
            user = acting_user
            if user && records.any? { |r|
                joiner = klass.find(:first, :conditions => construct_join_attributes(r))
                joiner.is_a?(Hobo::Model) && !joiner.destroyable_by?(user)
              }
              raise Hobo::PermissionDeniedError, "#{@owner.class}##{proxy_reflection.name}.destroy"
            end
            delete_records_without_hobo_permission_check(records)
          end
          alias_method_chain :delete_records, :hobo_permission_check
        
        end
      
        ActiveRecord::Associations::AssociationCollection.class_eval do
        
          # Helper - the user acting on the owner (if there is one)
          def acting_user
            @owner.acting_user if @owner.is_a?(Hobo::Model)
          end
                
          def create(attrs = {})
            if attrs.is_a?(Array)
              attrs.collect { |attr| create(attr) }
            else
              create_record(attrs) do |record|
                yield(record) if block_given?
                user = acting_user if record.is_a?(Hobo::Model)
                user ? record.user_save(user) : record.save
              end
            end
          end

          def create!(attrs = {})
            create_record(attrs) do |record|
              yield(record) if block_given?
              user = acting_user if record.is_a?(Hobo::Model)
              user ? record.user_save!(user) : record.save!
            end
          end
        
        end
      
      end
    
    end
  end  
  
end
