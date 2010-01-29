# An ActionView Helper
module Dryml::Helper
  def context_map(enum = this)
      # TODO: Calls to respond_to? in here can cause the full collection hiding behind a scoped collection to get loaded
      res = []
      empty = true
      scope.new_scope(:repeat_collection => enum, :even_odd => 'odd', :repeat_item => nil) do
        if enum.respond_to?(:each_pair)
          enum.each_pair do |key, value|
            scope.repeat_item = value
            empty = false;
            self.this_key = key;
            new_object_context(value) { res << yield }
            scope.even_odd = scope.even_odd == "even" ? "odd" : "even"
          end
        else
          index = 0
          enum.each do |e|
            scope.repeat_item = e
            empty = false;
            if enum == this
              new_field_context(index, e) { res << yield }
            else
              new_object_context(e) { res << yield }
            end
            scope.even_odd = scope.even_odd == "even" ? "odd" : "even"
            index += 1
          end
        end
        Dryml.last_if = !empty
      end
      res
    end
    
    def first_item?
      if scope.repeat_collection.respond_to? :each_pair
        this == scope.repeat_collection.first.try.last
      else
        this == scope.repeat_collection.first
      end
    end
    
    
    def last_item?
      if scope.repeat_collection.respond_to? :each_pair
        this == scope.repeat_collection.last.try.last
      else
        this == scope.repeat_collection.last
      end
    end

        def param_name_for(path)
      field_path = field_path.to_s.split(".") if field_path.is_one_of?(String, Symbol)
      attrs = path.rest.map{|part| "[#{part.to_s.sub /\?$/, ''}]"}.join
      "#{path.first}#{attrs}"
    end


    def param_name_for_this(foreign_key=false)
      return "" unless form_this
      name = if foreign_key && (refl = this_field_reflection) && refl.macro == :belongs_to
               param_name_for(path_for_form_field[0..-2] + [refl.primary_key_name])
             else
               param_name_for(path_for_form_field)
             end
      register_form_field(name)
      name
    end
end
