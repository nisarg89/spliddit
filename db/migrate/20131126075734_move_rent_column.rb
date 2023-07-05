class MoveRentColumn < ActiveRecord::Migration[7.0]
  def change
    remove_column :rent_division_instances, :rent
    add_column :instances, :rent, :decimal, :precision => 10, :scale => 2
  end
end
