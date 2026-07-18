class RemoveAdminFieldFromAgents < ActiveRecord::Migration[7.0]
  def up
    remove_column :agents, :admin
  end
end
