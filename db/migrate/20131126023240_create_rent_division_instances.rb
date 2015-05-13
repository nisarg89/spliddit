class CreateRentDivisionInstances < ActiveRecord::Migration
  def change
    create_table :rent_division_instances do |t|

      t.timestamps
    end
  end
end
