module Hobo

  module Scopes

    module ApplyScopes

      def apply_scopes(scopes)
        result = self
        scopes.each_pair do |scope, arg|
          if arg.is_a?(Array)
            result = result.send(scope, *arg) unless arg.first.blank?
          else
            result = result.send(scope, arg) unless arg.blank?
          end
        end
        result
      end

    end

  end

end
