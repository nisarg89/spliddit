class MoveRentColumn < ActiveRecord::Migration
  def change
    remove_column :rent_division_instances, :rent
    add_column :instances, :rent, :decimal, :precision => 10, :scale => 2
  end
end
