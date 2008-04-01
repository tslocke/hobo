class SwitchToStoryStatusModel < ActiveRecord::Migration
  def self.up
    create_table :story_statuses do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end
    
    add_column :stories, :status_id, :integer
    remove_column :stories, :status
  end

  def self.down
    remove_column :stories, :status_id
    add_column :stories, :status, :string
    
    drop_table :story_statuses
  end
end
