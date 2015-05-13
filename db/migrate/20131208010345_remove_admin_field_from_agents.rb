class RemoveAdminFieldFromAgents < ActiveRecord::Migration
  def up
    remove_column :agents, :admin
  end
end
