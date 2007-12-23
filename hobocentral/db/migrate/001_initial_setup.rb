class InitialSetup < ActiveRecord::Migration
  def self.up
    create_table :blog_post_comments do |t|
      t.string   :author
      t.text     :body
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :blog_post_id
    end
    
    create_table :blog_post_categories do |t|
      t.string :name
    end
    
    create_table :blog_post_categorisations do |t|
      t.integer :blog_post_category_id
      t.integer :blog_post_id
    end
    
    create_table :blog_posts do |t|
      t.string   :title
      t.text     :body
      t.datetime :created_at
      t.datetime :updated_at
    end
    
    create_table :forums do |t|
      t.string   :title
      t.text     :description
      t.datetime :created_at
      t.datetime :updated_at
    end
    
    create_table :forum_posts do |t|
      t.text     :body
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :topic_id
      t.integer  :user_id
    end
    
    create_table :forum_topics do |t|
      t.string   :title
      t.boolean  :sticky
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :forum_id
      t.integer  :user_id
    end
    
    create_table :users do |t|
      t.string   :crypted_password, :limit => 40
      t.string   :salt, :limit => 40
      t.string   :remember_token
      t.datetime :remember_token_expires_at
      t.string   :username
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :blog_post_comments
    drop_table :blog_post_categories
    drop_table :blog_post_categorisations
    drop_table :blog_posts
    drop_table :forums
    drop_table :forum_posts
    drop_table :forum_topics
    drop_table :users
  end
end
