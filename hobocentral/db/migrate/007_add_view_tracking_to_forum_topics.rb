class AddViewTrackingToForumTopics < ActiveRecord::Migration
  def self.up
    create_table :forum_topic_viewings do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :viewer_id
      t.integer  :target_id
    end
    
    add_column :forum_topics, :view_counter, :integer, :default => 0
  end

  def self.down
    remove_column :forum_topics, :view_counter
    
    drop_table :forum_topic_viewings
  end
end
