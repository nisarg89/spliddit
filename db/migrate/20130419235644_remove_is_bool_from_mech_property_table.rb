class RemoveIsBoolFromMechPropertyTable < ActiveRecord::Migration[7.0]
  def up
    remove_column :mech_properties, :isbool
  end

  def down
  end
end
