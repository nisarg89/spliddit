class MechanismsHaveAndBelongToManyMechPropertyValues < ActiveRecord::Migration[7.0]
  def self.up
    create_table :mechanisms_mech_property_values, :id => false do |t|
        t.references :mechanism
        t.references :mech_property_values
    end
  end

  def self.down
    drop_table :mechanisms_mech_property_values
  end
end