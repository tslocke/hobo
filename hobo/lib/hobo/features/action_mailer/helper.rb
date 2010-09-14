module Hobo
  module MailerHelper
    attr_reader :app_name, :host

    def initialize(*)
      super
      @app_name = Rails.application.config.hobo.app_name
      if self.class.default_url_options.empty?
        # might be set later in the before filter so we try to set it here
        d = Rails.application.config.action_mailer.default_url_options
        self.class.default_url_options = d.dup if d
      end
      @host = self.class.default_url_options[:host]
    end


    module ClassMethods
      def app_name
        @app_name ||= Rails.application.config.hobo.app_name
      end

      def host
        @host ||= begin
          if default_url_options[:host].nil?
            d = Rails.application.config.action_mailer.default_url_options
            d && d[:host].dup
          else
            default_url_options[:host]
          end
        end
      end
    end

  end
end

ActionMailer::Base.send :include, Hobo::MailerHelper
ActionMailer::Base.extend Hobo::MailerHelper::ClassMethods
