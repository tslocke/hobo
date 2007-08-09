module Hobo::Dryml
  
  class ScopedVariables
    
    def initialize
      @scopes = [{}]
    end
    
    def [](key)
      @scopes.reverse_each do |s|
        return s[key] if s.has_key?(key)
      end 
      nil
    end
    
    def []=(key, val)
      @scopes.last[key] = val
    end
    
    def new_scope
      @scopes << {}
      yield
      @scopes.pop
    end
    
    def method_missing(name)
      self[name]
    end
    
  end
  
end
