# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120926163657) do

  create_table "bars", :force => true do |t|
    t.string  "name"
    t.integer "foo_id"
  end

  add_index "bars", ["foo_id"], :name => "index_bars_on_foo_id"

  create_table "bats", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "baz_id"
  end

  add_index "bats", ["baz_id"], :name => "index_bats_on_baz_id"

  create_table "bazs", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "foobazs", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "foo_id"
    t.integer  "baz_id"
  end

  add_index "foobazs", ["baz_id"], :name => "index_foobazs_on_baz_id"
  add_index "foobazs", ["foo_id"], :name => "index_foobazs_on_foo_id"

  create_table "foos", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "bool1"
    t.boolean  "bool2"
    t.integer  "i"
    t.float    "f"
    t.decimal  "dec",                               :precision => 10, :scale => 4
    t.string   "s"
    t.text     "tt",            :limit => 16777215
    t.date     "d"
    t.datetime "dt"
    t.text     "hh"
    t.text     "tl"
    t.text     "md"
    t.string   "es",                                                               :default => "a"
    t.boolean  "v",                                                                :default => true
    t.string   "state",                                                            :default => "state1"
    t.datetime "key_timestamp"
  end

  add_index "foos", ["state"], :name => "index_foos_on_state"

  create_table "project_memberships", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "user_id"
    t.boolean  "contributor", :default => false
  end

  add_index "project_memberships", ["project_id"], :name => "index_project_memberships_on_project_id"
  add_index "project_memberships", ["user_id"], :name => "index_project_memberships_on_user_id"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "report_file_name"
    t.string   "report_content_type"
    t.integer  "report_file_size"
    t.datetime "report_updated_at"
  end

  add_index "projects", ["owner_id"], :name => "index_projects_on_owner_id"

  create_table "stories", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "status_id"
    t.string   "color",      :default => "#000000"
  end

  add_index "stories", ["project_id"], :name => "index_stories_on_project_id"
  add_index "stories", ["status_id"], :name => "index_stories_on_status_id"

  create_table "story_statuses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "task_assignments", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "task_id"
  end

  add_index "task_assignments", ["task_id"], :name => "index_task_assignments_on_task_id"
  add_index "task_assignments", ["user_id"], :name => "index_task_assignments_on_user_id"

  create_table "tasks", :force => true do |t|
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "story_id"
    t.integer  "position"
  end

  add_index "tasks", ["story_id"], :name => "index_tasks_on_story_id"

  create_table "users", :force => true do |t|
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "name"
    t.string   "email_address"
    t.boolean  "administrator",                           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                                   :default => "inactive"
    t.datetime "key_timestamp"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "users", ["state"], :name => "index_users_on_state"

end
