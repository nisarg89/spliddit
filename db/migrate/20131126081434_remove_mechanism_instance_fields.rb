class RemoveMechanismInstanceFields < ActiveRecord::Migration
  def change
    remove_column :agents, :mechanism_instance_id
    remove_column :agents, :mechanism_instance_type
    remove_column :resources, :mechanism_instance_id
    remove_column :resources, :mechanism_instance_type
  end
end
