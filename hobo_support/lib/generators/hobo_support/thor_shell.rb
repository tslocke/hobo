module Generators
  module HoboSupport
    module ThorShell

      PREFIX = '  => '

      private

      def ask(statement, default='', color=:magenta)
        result = super(statement, color)
        result = default if result.blank?
        say PREFIX + result.inspect
        result
      end

      def yes_no?(statement, color=:magenta)
        result = choose(statement + ' [y|n]', /^(y|n)$/i)
        result == 'y' ? true : false
      end

      def choose(prompt, format, default=nil)
        choice = ask prompt, default
        case
        when choice =~ format
          choice
        when choice.blank? && !default.blank?
          default
        else
          say 'Unknown choice! ', :red
          choose(prompt, format)
        end
      end

      def say_title(title)
        say "\n #{title} \n", "\e[37;44m"
      end

    end
  end
end
