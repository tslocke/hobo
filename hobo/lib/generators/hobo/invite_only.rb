module Generators
  module Hobo
    InviteOnly = classy_module do

      class_option :invite_only,
                 :aliases => '-i',
                 :type => :boolean,
                 :desc => "Add features for an invite only website"

      private

      def invite_only?
        options[:invite_only]
      end

    end
  end
end
