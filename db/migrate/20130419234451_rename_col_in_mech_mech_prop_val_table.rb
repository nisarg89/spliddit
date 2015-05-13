class RenameColInMechMechPropValTable < ActiveRecord::Migration
  def up
    rename_column :mech_property_values_mechanisms, :mech_property_values_id, :mech_property_value_id
  end

  def down
    rename_column :mech_property_values_mechanisms, :mech_property_value_id, :mech_property_values_id
  end
end
