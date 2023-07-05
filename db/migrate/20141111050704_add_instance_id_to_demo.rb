class AddInstanceIdToDemo < ActiveRecord::Migration[7.0]
  def change
    add_column :demos, :instance_id, :integer
    remove_column :demos, :input
    remove_column :demos, :output
    remove_column :demos, :status
  end
end
