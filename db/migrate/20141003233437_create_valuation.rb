class CreateValuation < ActiveRecord::Migration
  def change
    create_table :valuations do |t|
      t.integer :agent_id
      t.integer :resource_id
      t.integer :instance_id
      t.float :value
    end
  end
end
