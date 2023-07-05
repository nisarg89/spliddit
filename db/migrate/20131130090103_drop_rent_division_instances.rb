class DropRentDivisionInstances < ActiveRecord::Migration[7.0]
  def up
    drop_table :rent_division_instances
  end
end
