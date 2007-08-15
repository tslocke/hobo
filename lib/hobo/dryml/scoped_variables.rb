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
      res = yield
      @scopes.pop
      res
    end
    
    def method_missing(name, *args)
      if name =~ /=$/
        self[name] = args.first
      else
        self[name]
      end
    end
    
  end
  
end
