# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 5) do

  create_table "blog_post_categories", :force => true do |t|
    t.string "name"
  end

  create_table "blog_post_categorisations", :force => true do |t|
    t.integer "blog_post_category_id"
    t.integer "blog_post_id"
  end

  create_table "blog_post_comments", :force => true do |t|
    t.string   "author"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "blog_post_id"
  end

  create_table "blog_posts", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "author_id"
  end

  create_table "forum_posts", :force => true do |t|
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "topic_id"
    t.integer  "user_id"
  end

  create_table "forum_topics", :force => true do |t|
    t.string   "title"
    t.boolean  "sticky",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "forum_id"
    t.integer  "user_id"
    t.text     "body"
    t.datetime "last_post_at"
    t.integer  "last_post_by_id"
  end

  create_table "forums", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
