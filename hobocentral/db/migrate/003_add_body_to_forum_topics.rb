class AddBodyToForumTopics < ActiveRecord::Migration
  def self.up
    add_column :forum_topics, :body, :text
  end

  def self.down
    remove_column :forum_topics, :body
  end
end
