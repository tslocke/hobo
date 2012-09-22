class AddFoos < ActiveRecord::Migration
  def self.up
    create_table :foobazs do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :foo_id
      t.integer  :baz_id
    end
    add_index :foobazs, [:foo_id]
    add_index :foobazs, [:baz_id]

    create_table :foos do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.boolean  :bool1
      t.boolean  :bool2
      t.integer  :i
      t.float    :f
      t.decimal  :dec, :precision => 10, :scale => 4
      t.string   :s
      t.text     :tt, :limit => 16777215
      t.date     :d
      t.datetime :dt
      t.text     :hh
      t.text     :tl
      t.text     :md
      t.string   :es, :default => "a"
      t.boolean  :v, :default => true
      t.string   :state, :default => "state1"
      t.datetime :key_timestamp
    end
    add_index :foos, [:state]

    create_table :bazs do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :bats do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :baz_id
    end
    add_index :bats, [:baz_id]

    create_table :bars do |t|
      t.string  :name
      t.integer :foo_id
    end
    add_index :bars, [:foo_id]
  end

  def self.down
    drop_table :foobazs
    drop_table :foos
    drop_table :bazs
    drop_table :bats
    drop_table :bars
  end
end
