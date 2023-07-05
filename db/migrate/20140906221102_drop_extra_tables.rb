class DropExtraTables < ActiveRecord::Migration[7.0]
  def change
    drop_table :mech_properties
    drop_table :mech_property_values
    drop_table :mech_property_values_mechanisms
    drop_table :mechanisms
  end
end
