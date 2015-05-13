class AddRentToRentDivisionInstances < ActiveRecord::Migration
  def change
    add_column :rent_division_instances, :rent, :decimal, :precision => 10, :scale => 2
  end
end
