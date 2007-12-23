class AddAuthorToBlogPosts < ActiveRecord::Migration
  def self.up
    add_column :blog_posts, :author_id, :integer
  end

  def self.down
    remove_column :blog_posts, :author_id
  end
end
