module Hobo 

  class Guest
    
    alias_method :has_hobo_method?, :respond_to?
    
    def to_s
      "Guest"
    end

    def guest?
      true
    end

    def signed_up?
      false
    end
    
    def super_user?
      false
    end
    
    def administrator?
      false
    end

  end

end
