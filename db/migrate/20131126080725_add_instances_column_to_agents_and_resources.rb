class AddInstancesColumnToAgentsAndResources < ActiveRecord::Migration
  def change
    add_column :agents, :instance_id, :integer
    add_column :resources, :instance_id, :integer
  end
end
