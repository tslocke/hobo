class AddColorToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :color, :string, :default => "#000000"
  end

  def self.down
    remove_column :stories, :color
  end
end
