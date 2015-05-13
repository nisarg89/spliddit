class CreateMechProperties < ActiveRecord::Migration
  def change
    create_table :mech_properties do |t|
      t.string :name
      t.string :definition
      t.boolean :isbool, default: false
      t.integer :problem_id
      t.timestamps
    end
  end
end
