class DropInstancesTable < ActiveRecord::Migration
  def change
    drop_table :instances
  end
end
