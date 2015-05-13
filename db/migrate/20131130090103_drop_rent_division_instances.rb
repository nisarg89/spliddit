class DropRentDivisionInstances < ActiveRecord::Migration
  def up
    drop_table :rent_division_instances
  end
end
