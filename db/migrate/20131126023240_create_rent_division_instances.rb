class CreateRentDivisionInstances < ActiveRecord::Migration[7.0]
  def change
    create_table :rent_division_instances do |t|

      t.timestamps
    end
  end
end
