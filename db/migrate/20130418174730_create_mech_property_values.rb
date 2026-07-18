class CreateMechPropertyValues < ActiveRecord::Migration[7.0]
  def change
    create_table :mech_property_values do |t|
      t.string :value
      t.integer :mech_property_id
      t.timestamps
    end
  end
end
