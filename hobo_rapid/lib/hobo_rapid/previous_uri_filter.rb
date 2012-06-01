module HoboRapid
  # this after_filter is useful for the after_submit tag
  class PreviousUriFilter
    def self.filter(controller)
      if controller.request.get?
        controller.session[:previous_uri] = controller.request.path
      end
    end
  end
end
