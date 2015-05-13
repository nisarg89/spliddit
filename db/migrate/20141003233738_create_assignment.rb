class CreateAssignment < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.integer :agent_id
      t.integer :resource_id
      t.integer :instance_id
      t.float :ownership
      t.float :price
    end
  end
end
