class AddAdminToAgentsTable < ActiveRecord::Migration
  def change
    add_column :agents, :admin, :boolean, default: false
  end
end
