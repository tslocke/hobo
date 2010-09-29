module Generators
  module HoboSupport
    module ThorShell

      PREFIX = '  => '

      private

      def ask(statement, default='', color=Thor::Shell::Color::MAGENTA)
        result = super(statement, color)
        result = default if result.blank?
        say PREFIX + result.inspect
        result
      end

      def yes_no?(statement, color=Thor::Shell::Color::MAGENTA)
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
          say 'Unknown choice! ', Thor::Shell::Color::RED
          choose(prompt, format)
        end
      end

      def say_title(title)
        say "\n #{title} \n", "\e[37;44m"
      end

      def multi_ask(statement)
        result = []
        while (r = ask(statement)) && !r.blank?
          result << r
        end
        result
      end

    end
  end
end
