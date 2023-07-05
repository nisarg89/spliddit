class DropInstancesTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :instances
  end
end
