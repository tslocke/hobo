class Init < ActiveRecord::Migration
  def self.up
    create_table :administrators do |t|
      t.string   :crypted_password, :limit => 40
      t.string   :salt, :limit => 40
      t.string   :remember_token
      t.datetime :remember_token_expires_at
      t.string   :name
    end
    
    create_table :categorisations do |t|
      t.integer :post_id
      t.integer :category_id
    end
    
    create_table :categories do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end
    
    create_table :comments do |t|
      t.text     :body
      t.string   :author
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :post_id
    end
    
    create_table :posts do |t|
      t.string   :title
      t.text     :body
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :user_id
    end
    
    create_table :users do |t|
      t.string   :crypted_password, :limit => 40
      t.string   :salt, :limit => 40
      t.string   :remember_token
      t.datetime :remember_token_expires_at
      t.string   :name
    end
  end

  def self.down
    drop_table :administrators
    drop_table :categorisations
    drop_table :categories
    drop_table :comments
    drop_table :posts
    drop_table :users
  end
end
