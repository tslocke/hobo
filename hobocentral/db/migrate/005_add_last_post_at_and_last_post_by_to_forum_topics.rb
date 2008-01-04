class AddLastPostAtAndLastPostByToForumTopics < ActiveRecord::Migration
  def self.up
    add_column :forum_topics, :last_post_at, :datetime
    add_column :forum_topics, :last_post_by_id, :integer
  end

  def self.down
    remove_column :forum_topics, :last_post_at
    remove_column :forum_topics, :last_post_by_id
  end
end
