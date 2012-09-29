class ProjectOwnership < ActiveRecord::Migration
  def self.up
    add_column :projects, :owner_id, :integer

    add_index :projects, [:owner_id]
  end

  def self.down
    remove_column :projects, :owner_id

    remove_index :projects, :name => :index_projects_on_owner_id rescue ActiveRecord::StatementInvalid
  end
end
