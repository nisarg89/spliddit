class AddForeignKeyToMechanismsFromInstances < ActiveRecord::Migration[7.0]
  def change
    add_column :instances, :mechanism_id, :integer
  end
end
