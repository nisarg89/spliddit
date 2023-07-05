class RenameMechanismMechPropJoinTable < ActiveRecord::Migration[7.0]
  def self.up
      rename_table :mechanisms_mech_property_values, :mech_property_values_mechanisms
  end 
  def self.down
      rename_table :mech_property_values_mechanisms, :mechanisms_mech_property_values
  end
end
