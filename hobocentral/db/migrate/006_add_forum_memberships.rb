class AddForumMemberships < ActiveRecord::Migration
  def self.up
    create_table :forum_memberships do |t|
      t.boolean  :moderator
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :forum_id
      t.integer  :user_id
    end
  end

  def self.down
    drop_table :forum_memberships
  end
end
