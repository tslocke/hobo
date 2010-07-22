class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    <%= up %>
  end

  def self.down
    <%= down %>
  end
end
