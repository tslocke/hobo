module HoboHelperBase

    def add_to_controller(controller)
      controller.send(:include, self)
      controller.hide_action(self.instance_methods)
    end

end
