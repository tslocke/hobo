class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= table_name %> do |t|
      t.string   :username
      t.string   :crypted_password, :salt, :limit => 40
      t.string   :remember_token
      t.datetime :remember_token_expires_at
      t.auto_dates
    end
  end

  def self.down
    drop_table :<%= table_name %>
  end
end
