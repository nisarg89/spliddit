class RemoveLimitMechPropertyDefinition < ActiveRecord::Migration[7.0]
  def change
    change_column :mech_properties, :definition, :text, :limit => nil
  end
end
