module HoboSupport
  module Generators
    module ChooseModule

      def choose(prompt, format)
        choice = ask prompt
        (choice =~ format) ? choice : choose(prompt, format)
      end

    end
  end
end
