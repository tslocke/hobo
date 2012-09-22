class ProjcetContributors < ActiveRecord::Migration
  def self.up
    add_column :project_memberships, :contributor, :boolean, :default => false
  end

  def self.down
    remove_column :project_memberships, :contributor
  end
end
