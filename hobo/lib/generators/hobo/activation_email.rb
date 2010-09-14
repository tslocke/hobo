module Generators
  module Hobo
    ActivationEmail = classy_module do

      class_option :activation_email,
                 :type => :boolean,
                 :desc => "Send an email to activate the account"

    end
  end
end
