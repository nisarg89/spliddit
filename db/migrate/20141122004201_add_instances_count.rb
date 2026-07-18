class AddInstancesCount < ActiveRecord::Migration[7.0]
  def change
    add_column :applications, :instances_count, :integer, :default => 0
  end

end
