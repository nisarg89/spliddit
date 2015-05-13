class AddForeignKeyToMechanismsFromInstances < ActiveRecord::Migration
  def change
    add_column :instances, :mechanism_id, :integer
  end
end
