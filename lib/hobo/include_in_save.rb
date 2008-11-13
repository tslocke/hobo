module Hobo
  
  IncludeInSave = classy_module do
    
    attr_accessor :included_in_save
    
    validate         :validate_included_in_save
    before_save      :save_included
    after_save       :clear_included_in_save    
    
    def include_in_save(association, *records)
      self.included_in_save ||= Hash.new {|h, k| h[k] = []}
      included_in_save[association.to_sym].concat records
    end
    
    def validate_included_in_save
      if included_in_save
        included_in_save._?.each_pair do |association, records|
          added = false
          records.each do |record|
            # we want to call valid? on each one, but only add the error to self once
            unless record.valid?
              unless added
                errors.add association, "..."
                added = true
              end
            end
          end
        end
      end
    end


    def save_included
      if included_in_save
        included_in_save.each_pair do |association, records|
          records.each do |record|
            record.save_without_validation # This means without transactions too
          end
        end
      end
    end

    def clear_included_in_save
      included_in_save._?.clear
    end

  end

end
