module Hobo

  class Guest

    alias_method :has_hobo_method?, :respond_to?

    def to_s
      "guest"
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

    def login
      "guest"
    end

  end

end
