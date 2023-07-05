class AddInstancesColumnToAgentsAndResources < ActiveRecord::Migration[7.0]
  def change
    add_column :agents, :instance_id, :integer
    add_column :resources, :instance_id, :integer
  end
end
