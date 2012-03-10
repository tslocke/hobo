require '<%= @filename %>'
require 'rails'

module <%= @module_name %>
  class Railtie < Rails::Railtie
  end
end
