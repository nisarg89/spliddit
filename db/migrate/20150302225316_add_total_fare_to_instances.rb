class AddTotalFareToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :total_fare, :float
  end
end
