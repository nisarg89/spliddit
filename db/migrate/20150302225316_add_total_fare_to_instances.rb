class AddTotalFareToInstances < ActiveRecord::Migration[7.0]
  def change
    add_column :instances, :total_fare, :float
  end
end
