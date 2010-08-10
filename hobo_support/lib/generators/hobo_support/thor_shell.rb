module Generators
  module HoboSupport
    module ThorShell

      PREFIX = '  => '

      private

      def say(message="", color=Thor::Shell::Color::GREEN, force_new_line=(message.to_s !~ /( |\t)$/))
        super
      end

      def ask(statement, default='', color=Thor::Shell::Color::MAGENTA)
        result = super(statement, color)
        result = default if result.blank?
        say PREFIX + result
        result
      end

      def yes_no?(statement, color=Thor::Shell::Color::MAGENTA)
        result = choose(statement + ' [y|n]', /^(y|n)$/i)
        result == 'y' ? true : false
      end

      def choose(prompt, format)
        choice = ask prompt
        if choice =~ format
          choice
        else
          say 'Wrong choice! '
          choose(prompt, format)
        end
      end

    end
  end
end
