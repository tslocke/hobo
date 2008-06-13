module Hobo::Dryml::Parser

  class Text < REXML::Text

    def parent=(parent)
      # Bypass immediate super
      REXML::Child.instance_method(:parent=).bind(self).call(parent)
      Text.check(@string, /</, nil) if @raw and @parent && Text.respond_to?(:check)
    end

  end

end
