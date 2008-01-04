class AddDefaultToForumTopicsSticky < ActiveRecord::Migration
  def self.up
    change_column :forum_topics, :sticky, :boolean, :default => false
  end

  def self.down
    change_column :forum_topics, :sticky, :boolean
  end
end
