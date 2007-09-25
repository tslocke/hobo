module Hobo
  
  module HttpParameters
    
    class PermissionDeniedError < RuntimeError; end
    class InvalidError < RuntimeError; end
    
    def initialize_record(record, params)
      update_without_tracking(record, params)
      record.set_creator(current_user)
      (@to_create ||= []) << record
      record
    end

    
    def update_record(record, params)
      return if params.blank?
      
      original = record.duplicate
      # 'duplicate' can set these, but they can
      # conflict with the changes so we clear them
      @this.send(:clear_aggregation_cache)
      @this.send(:clear_association_cache)
      
      (@to_update ||= []) << [original, record]

      update_without_tracking(record, params)
    end
    
    
    def update_without_tracking(record, params)
      params && params.each_pair do |field_name, value|
        field = if (create = field_name =~ /^new_/)
                  field_name[4..-1].to_sym
                else
                  field_name.to_sym
                end
        refl = record.class.reflections[field]
        
        if refl._?.macro == :belongs_to
          if create
            new_for_belongs_to(record, refl, value)
          else
            update_belongs_to(record, refl, value)
          end
          
        elsif Hobo.simple_has_many_association?(refl)
          raise HoboError, "invalid HTTP parameter #{field_name}" if create
          update_has_many(record, refl, value)
          
        else
          raise HoboError, "invalid HTTP parameter #{field_name}" if create
          update_primitive(record, field, value)
          
        end
      end
    end
    
    
    def new_for_belongs_to(record, refl, fields)
      # person[+home][address]=blah  Create new home and set address (PUT POST)

      target = refl.klass.new
      initialize_record(target, fields)
      record.send("#{refl.name}=", target)
    end
    
    
    def update_belongs_to(record, refl, value)
      if value.is_a? String
        # Update belongs_to to reference some existing record

        target = if value.starts_with?('@')
                   # person[home]=@home_12  Reference different existing home (PUT POST)
                   
                   Hobo.object_from_dom_id(value[1..-1])
                 elsif refl.klass.id_name?
                   # product[category]=garden  Reference existing category with id or name (PUT POST)
                   
                   refl.klass.find_by_id_name(value)
                 else
                   raise HoboError, "invalid HTTP parameter" if create
                 end
        record.send("#{refl.name}=", target)
        
      else
        # Update state of current belongs_to target
        # person[home][address]=blah  Update existing home.address (PUT)
        raise HoboError, "invalid HTTP parameter" unless params[:action] == "update"
        
        target = record.send(refl.name)
        raise HoboError, "invalid HTTP parameter" if target.nil?
        update_record(target, value)
      end
    end
    
    
    def update_has_many(record, refl, items)
      new_items, changed_items = items.partition_hash {|k,v| k =~ /^\+/}
      
      new_items.keys.sort_by{|k|k.to_i}.each do |k|
        # home[people][+1][name]=blah Create new Person with fkey refing to this home and set name (PUT POST)
        fields = new_items[k]
        new_for_has_many(record, refl, fields)
      end
      
      changed_items.each_pair do |id, value|
        # Change to existing record - only valid on PUTs
        raise HoboError, "invalid HTTP parameter" unless params[:action] == "update"
        
        target = id =~ /_/ ? Hobo.object_from_dom_id(id) : refl.klass.find(id)
        # Ensure the target is actually in this has_many
        raise HoboError, "invalid http parameter" unless target.send(refl.primary_key_name) == record.id
        
        if value.is_a?(String) && value.downcase == "delete"
          # home[people][45]=delete  Delete Person[45] (PUT)
          delete_record(target)
          
        else
          # home[people][45][name]=blah  Update Person[45].name (PUT)
          raise HoboError, "invalid http parameter" unless value.is_a?(Hash) # field/value pairs
          update_record(target, value)
          
        end
      end
    end
    
    
    def new_for_has_many(record, refl, value)
      # home[people][+1][name]=blah Create new Person with fkey refing to this home and set name (PUT POST)

      new_record = record.send(refl.name).new
      initialize_record(new_record, value)
      record.send("#{refl.name}").target << new_record
    end
    
    
    def delete_record(record)
      raise HoboError, "invalid HTTP parameter" unless params[:action] == "update"
      (@to_delete ||= []) << record
    end
    
    
    def update_primitive(record, field, value)
      # person[name]=fred (POST PUT)
      field_type = record.class.field_type(field)
      record.send("#{field}=", param_to_value(field_type, value))
    end
    
    
    def parse_datetime(s)
      defined?(Chronic) ? Chronic.parse(s) : Time.parse(s)
    end


    def param_to_value(field_type, value)
      if field_type.nil?
        value
      elsif field_type <= Date
        if value.is_a? Hash
          Date.new(*(%w{year month day}.map{|s| value[s].to_i}))
        elsif value.is_a? String
          dt = parse_datetime(value)
          dt && dt.to_date
        end
      elsif field_type <= Time
        if value.is_a? Hash
          Time.local(*(%w{year month day hour minute}.map{|s| value[s].to_i}))
        elsif value.is_a? String
          parse_datetime(value)
        end
      elsif field_type <= TrueClass
        (value.is_a?(String) && value.strip.downcase.in?(['0', 'false']) || value.blank?) ? false : true
      else
        # primitive field
        value
      end
    end
    
    
    def check_permissions_and_apply_changes
      valid = true
      for old, new in @to_update
        raise PermissionDeniedError unless Hobo.can_update?(current_user, old, new)
        new_valid = new.save
        valid &&= new_valid
      end if @to_update
      
      for record in @to_create
        raise PermissionDeniedError unless Hobo.can_create?(current_user, record)
        # check if it's new because it might have already been saved as a result of the updates
        record_valid = record.save if record.new_record?
        valid &&= record_valid
      end if @to_create

      for record in @to_delete
        raise PermissionDeniedError unless Hobo.can_delete?(current_user, record)
        record.destroy
      end if @to_delete
      
      valid
    ensure
      @to_update = @to_create = @to_delete = nil
    end
    
    
    def secure_change_transaction
      valid = nil
      begin
        ActiveRecord::Base.transaction do
          yield 
          valid = check_permissions_and_apply_changes
          raise InvalidError unless valid
        end
      rescue PermissionDeniedError
        return :not_allowed
      rescue InvalidError
        return :invalid
      end
      :valid
    end
    
  end

end
