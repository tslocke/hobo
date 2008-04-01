class AddPositionToTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :position, :integer
  end

  def self.down
    remove_column :tasks, :position
  end
end
