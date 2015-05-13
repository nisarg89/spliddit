class RemoveIsBoolFromMechPropertyTable < ActiveRecord::Migration
  def up
    remove_column :mech_properties, :isbool
  end

  def down
  end
end
