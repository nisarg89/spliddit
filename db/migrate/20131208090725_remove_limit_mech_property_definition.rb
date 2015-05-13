class RemoveLimitMechPropertyDefinition < ActiveRecord::Migration
  def change
    change_column :mech_properties, :definition, :text, :limit => nil
  end
end
